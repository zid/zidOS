#include "panic.h"
#include "mem.h"

#define LINKER_VAR(x) (unsigned long)(&x)
#define KERN_VIRT_TO_PHYS(x) ((unsigned long)x - 0xFFFFFFFF80000000)
#define PHYS_TO_VIRT(x) (0xFFFF800000000000 | x)

extern unsigned long VIRT, BSS_OFFSET, BSS_LEN;
static unsigned long kernel_size;

struct block {
	unsigned long addr;
	unsigned long length;
};

static struct block freelist[4096/sizeof(struct block)];
static int block_index;

static int addr_to_pml4_index(unsigned long vaddr)
{
	/* De-sign-extend and divide by 512GB */
	return (vaddr>>39)&0x1FF;
}

static int addr_to_pdpt_index(unsigned long vaddr)
{
	/* Remove sign extension, round to nearest 512GB, divide by 1GB */
	return (vaddr & 0x7FFFFFFFFF)/(0x40000000);
}

/* Create a 2MB page directory, mapping up to 1GB */
unsigned long create_page_directory(unsigned long *page, unsigned long physical, int entries)
{
	int i;

	unsigned long *pd;

	pd = (unsigned long *)*page;
	*page += 4096;

	for(i = 0; i < entries; i++)
	{
		pd[i] = (physical&0xFFFFFFFFFFE00000) | 0x83;
		physical += 0x200000;
	}

	return KERN_VIRT_TO_PHYS(pd);
}

static void pdpt_insert(unsigned long *PML4, unsigned long vaddr, unsigned long pd_phys, unsigned long *kernel_end)
{
	int i;
	unsigned long *pdpt;

	i = addr_to_pml4_index(vaddr);

	pdpt = (unsigned long *)PML4[i];

	if(!pdpt)
	{
		pdpt = KERN_VIRT_TO_PHYS(*kernel_end);
		PML4[i] = (unsigned long)pdpt | 0x3;
		*kernel_end += 4096;
	}

	i = addr_to_pdpt_index(vaddr);
	pdpt[i] = pd_phys | 0x3;
}

/* For each entry in the e820 provided physical memory map
 * create a mapping in the pml4[511] PDPT which maps it to
 * a base address of 0xFFFF800000000000. Such that physical
 * address 0 has virtual address 0xFFFF800000000000.
 */
static void phys_to_virt_map(unsigned long *kernel_end, unsigned long *PML4, unsigned long addr, unsigned long length)
{
	int entries;

	/* Create 2MB tables */
	entries = (length / 0x200000)+1;

	while(1)
	{
		int n;
		unsigned long pd_phys;

		n = entries > 512 ? 512 : entries;

		pd_phys = create_page_directory(kernel_end, addr, n);

		pdpt_insert(PML4, PHYS_TO_VIRT(addr), pd_phys, kernel_end);

		addr += 0x40000000; /* 1GB */;
		entries -= 512;
		if(entries < 0)
			break;
	}
}

static void mem_reserve_init(unsigned long kernel_end)
{
	/* TODO: Make this work if the kernel isn't at 1MB */
	unsigned long kernel_size;

	kernel_size = kernel_end - freelist[0].addr;

	freelist[0].addr += kernel_size;
	freelist[0].length -= kernel_size;
}

/* Generate virtual addresses for all the physical memory we know about */
static void virt_init(void)
{
	int i;

	/* Our PML4 table is hardcoded into the BSS */
	unsigned long *PML4 = (unsigned long *)(LINKER_VAR(VIRT) + LINKER_VAR(BSS_OFFSET) + 0x4000);

	/* These pages are after the end of the kernel,
	 * but the bootstrap has mapped significantly
	 * more memory than that for us, so we can
	 * use this space to create some page tables with.
	 */
	unsigned long kernel_end = LINKER_VAR(VIRT) + LINKER_VAR(BSS_OFFSET) + LINKER_VAR(BSS_LEN);

	for(i = 0; i < block_index; i++)
	{
		phys_to_virt_map(&kernel_end, PML4, freelist[i].addr, freelist[i].length);
	}

	reload_page_table((unsigned long)PML4 );

	/* Reserve memory we've already used */
	mem_reserve_init(kernel_end);
}

static void mem_add_region(unsigned long base, unsigned long len, unsigned int type)
{
	if(type != 1)
		return;

	freelist[block_index].addr = base;
	freelist[block_index].length = len;

	block_index++;
}

void mem_init(unsigned int *map)
{
	unsigned long map_length, map_addr;

	/* Parse the e820 map given to us by the bootloader */
	map_length = map[11];
	map_addr   = map[12];

	map_addr += 4;

	while(map_length)
	{
		int type;
		unsigned long base_addr;
		unsigned long length;

		base_addr = *(unsigned long *)map_addr;
		length    = *(unsigned long *)(map_addr+8);
		type      = *(unsigned int *)(map_addr+16);

		mem_add_region(base_addr, length, type);

		map_length -= 24;
		map_addr += 24;
	}

	/* Initialise virtual memory */
	virt_init();

}

