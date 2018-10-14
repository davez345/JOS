
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 56 00 00 00       	call   f0100094 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 a0 18 10 f0       	push   $0xf01018a0
f0100050:	e8 1a 09 00 00       	call   f010096f <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7e 11                	jle    f010006d <test_backtrace+0x2d>
		test_backtrace(x-1);
f010005c:	83 ec 0c             	sub    $0xc,%esp
f010005f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100062:	50                   	push   %eax
f0100063:	e8 d8 ff ff ff       	call   f0100040 <test_backtrace>
f0100068:	83 c4 10             	add    $0x10,%esp
f010006b:	eb 11                	jmp    f010007e <test_backtrace+0x3e>
	else
		mon_backtrace(0, 0, 0);
f010006d:	83 ec 04             	sub    $0x4,%esp
f0100070:	6a 00                	push   $0x0
f0100072:	6a 00                	push   $0x0
f0100074:	6a 00                	push   $0x0
f0100076:	e8 0a 07 00 00       	call   f0100785 <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 bc 18 10 f0       	push   $0xf01018bc
f0100087:	e8 e3 08 00 00       	call   f010096f <cprintf>
}
f010008c:	83 c4 10             	add    $0x10,%esp
f010008f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100092:	c9                   	leave  
f0100093:	c3                   	ret    

f0100094 <i386_init>:

void
i386_init(void)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010009a:	b8 44 29 11 f0       	mov    $0xf0112944,%eax
f010009f:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 23 11 f0       	push   $0xf0112300
f01000ac:	e8 57 13 00 00       	call   f0101408 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 9d 04 00 00       	call   f0100553 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 d7 18 10 f0       	push   $0xf01018d7
f01000c3:	e8 a7 08 00 00       	call   f010096f <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000c8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000cf:	e8 6c ff ff ff       	call   f0100040 <test_backtrace>
f01000d4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000d7:	83 ec 0c             	sub    $0xc,%esp
f01000da:	6a 00                	push   $0x0
f01000dc:	e8 21 07 00 00       	call   f0100802 <monitor>
f01000e1:	83 c4 10             	add    $0x10,%esp
f01000e4:	eb f1                	jmp    f01000d7 <i386_init+0x43>

f01000e6 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000e6:	55                   	push   %ebp
f01000e7:	89 e5                	mov    %esp,%ebp
f01000e9:	56                   	push   %esi
f01000ea:	53                   	push   %ebx
f01000eb:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000ee:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f01000f5:	75 37                	jne    f010012e <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000f7:	89 35 40 29 11 f0    	mov    %esi,0xf0112940

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f01000fd:	fa                   	cli    
f01000fe:	fc                   	cld    

	va_start(ap, fmt);
f01000ff:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100102:	83 ec 04             	sub    $0x4,%esp
f0100105:	ff 75 0c             	pushl  0xc(%ebp)
f0100108:	ff 75 08             	pushl  0x8(%ebp)
f010010b:	68 f2 18 10 f0       	push   $0xf01018f2
f0100110:	e8 5a 08 00 00       	call   f010096f <cprintf>
	vcprintf(fmt, ap);
f0100115:	83 c4 08             	add    $0x8,%esp
f0100118:	53                   	push   %ebx
f0100119:	56                   	push   %esi
f010011a:	e8 2a 08 00 00       	call   f0100949 <vcprintf>
	cprintf("\n");
f010011f:	c7 04 24 ef 1b 10 f0 	movl   $0xf0101bef,(%esp)
f0100126:	e8 44 08 00 00       	call   f010096f <cprintf>
	va_end(ap);
f010012b:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010012e:	83 ec 0c             	sub    $0xc,%esp
f0100131:	6a 00                	push   $0x0
f0100133:	e8 ca 06 00 00       	call   f0100802 <monitor>
f0100138:	83 c4 10             	add    $0x10,%esp
f010013b:	eb f1                	jmp    f010012e <_panic+0x48>

f010013d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010013d:	55                   	push   %ebp
f010013e:	89 e5                	mov    %esp,%ebp
f0100140:	53                   	push   %ebx
f0100141:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100144:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100147:	ff 75 0c             	pushl  0xc(%ebp)
f010014a:	ff 75 08             	pushl  0x8(%ebp)
f010014d:	68 0a 19 10 f0       	push   $0xf010190a
f0100152:	e8 18 08 00 00       	call   f010096f <cprintf>
	vcprintf(fmt, ap);
f0100157:	83 c4 08             	add    $0x8,%esp
f010015a:	53                   	push   %ebx
f010015b:	ff 75 10             	pushl  0x10(%ebp)
f010015e:	e8 e6 07 00 00       	call   f0100949 <vcprintf>
	cprintf("\n");
f0100163:	c7 04 24 ef 1b 10 f0 	movl   $0xf0101bef,(%esp)
f010016a:	e8 00 08 00 00       	call   f010096f <cprintf>
	va_end(ap);
}
f010016f:	83 c4 10             	add    $0x10,%esp
f0100172:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100175:	c9                   	leave  
f0100176:	c3                   	ret    

f0100177 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100177:	55                   	push   %ebp
f0100178:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010017a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010017f:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100180:	a8 01                	test   $0x1,%al
f0100182:	74 0b                	je     f010018f <serial_proc_data+0x18>
f0100184:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100189:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010018a:	0f b6 c0             	movzbl %al,%eax
f010018d:	eb 05                	jmp    f0100194 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010018f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100194:	5d                   	pop    %ebp
f0100195:	c3                   	ret    

f0100196 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100196:	55                   	push   %ebp
f0100197:	89 e5                	mov    %esp,%ebp
f0100199:	53                   	push   %ebx
f010019a:	83 ec 04             	sub    $0x4,%esp
f010019d:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010019f:	eb 2b                	jmp    f01001cc <cons_intr+0x36>
		if (c == 0)
f01001a1:	85 c0                	test   %eax,%eax
f01001a3:	74 27                	je     f01001cc <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01001a5:	8b 0d 24 25 11 f0    	mov    0xf0112524,%ecx
f01001ab:	8d 51 01             	lea    0x1(%ecx),%edx
f01001ae:	89 15 24 25 11 f0    	mov    %edx,0xf0112524
f01001b4:	88 81 20 23 11 f0    	mov    %al,-0xfeedce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001ba:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001c0:	75 0a                	jne    f01001cc <cons_intr+0x36>
			cons.wpos = 0;
f01001c2:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
f01001c9:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001cc:	ff d3                	call   *%ebx
f01001ce:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001d1:	75 ce                	jne    f01001a1 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001d3:	83 c4 04             	add    $0x4,%esp
f01001d6:	5b                   	pop    %ebx
f01001d7:	5d                   	pop    %ebp
f01001d8:	c3                   	ret    

f01001d9 <kbd_proc_data>:
f01001d9:	ba 64 00 00 00       	mov    $0x64,%edx
f01001de:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01001df:	a8 01                	test   $0x1,%al
f01001e1:	0f 84 f8 00 00 00    	je     f01002df <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01001e7:	a8 20                	test   $0x20,%al
f01001e9:	0f 85 f6 00 00 00    	jne    f01002e5 <kbd_proc_data+0x10c>
f01001ef:	ba 60 00 00 00       	mov    $0x60,%edx
f01001f4:	ec                   	in     (%dx),%al
f01001f5:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001f7:	3c e0                	cmp    $0xe0,%al
f01001f9:	75 0d                	jne    f0100208 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01001fb:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f0100202:	b8 00 00 00 00       	mov    $0x0,%eax
f0100207:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100208:	55                   	push   %ebp
f0100209:	89 e5                	mov    %esp,%ebp
f010020b:	53                   	push   %ebx
f010020c:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010020f:	84 c0                	test   %al,%al
f0100211:	79 36                	jns    f0100249 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100213:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100219:	89 cb                	mov    %ecx,%ebx
f010021b:	83 e3 40             	and    $0x40,%ebx
f010021e:	83 e0 7f             	and    $0x7f,%eax
f0100221:	85 db                	test   %ebx,%ebx
f0100223:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100226:	0f b6 d2             	movzbl %dl,%edx
f0100229:	0f b6 82 80 1a 10 f0 	movzbl -0xfefe580(%edx),%eax
f0100230:	83 c8 40             	or     $0x40,%eax
f0100233:	0f b6 c0             	movzbl %al,%eax
f0100236:	f7 d0                	not    %eax
f0100238:	21 c8                	and    %ecx,%eax
f010023a:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f010023f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100244:	e9 a4 00 00 00       	jmp    f01002ed <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100249:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f010024f:	f6 c1 40             	test   $0x40,%cl
f0100252:	74 0e                	je     f0100262 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100254:	83 c8 80             	or     $0xffffff80,%eax
f0100257:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100259:	83 e1 bf             	and    $0xffffffbf,%ecx
f010025c:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	}

	shift |= shiftcode[data];
f0100262:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100265:	0f b6 82 80 1a 10 f0 	movzbl -0xfefe580(%edx),%eax
f010026c:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
f0100272:	0f b6 8a 80 19 10 f0 	movzbl -0xfefe680(%edx),%ecx
f0100279:	31 c8                	xor    %ecx,%eax
f010027b:	a3 00 23 11 f0       	mov    %eax,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100280:	89 c1                	mov    %eax,%ecx
f0100282:	83 e1 03             	and    $0x3,%ecx
f0100285:	8b 0c 8d 60 19 10 f0 	mov    -0xfefe6a0(,%ecx,4),%ecx
f010028c:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100290:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100293:	a8 08                	test   $0x8,%al
f0100295:	74 1b                	je     f01002b2 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f0100297:	89 da                	mov    %ebx,%edx
f0100299:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010029c:	83 f9 19             	cmp    $0x19,%ecx
f010029f:	77 05                	ja     f01002a6 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f01002a1:	83 eb 20             	sub    $0x20,%ebx
f01002a4:	eb 0c                	jmp    f01002b2 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f01002a6:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002a9:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002ac:	83 fa 19             	cmp    $0x19,%edx
f01002af:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002b2:	f7 d0                	not    %eax
f01002b4:	a8 06                	test   $0x6,%al
f01002b6:	75 33                	jne    f01002eb <kbd_proc_data+0x112>
f01002b8:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002be:	75 2b                	jne    f01002eb <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01002c0:	83 ec 0c             	sub    $0xc,%esp
f01002c3:	68 24 19 10 f0       	push   $0xf0101924
f01002c8:	e8 a2 06 00 00       	call   f010096f <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002cd:	ba 92 00 00 00       	mov    $0x92,%edx
f01002d2:	b8 03 00 00 00       	mov    $0x3,%eax
f01002d7:	ee                   	out    %al,(%dx)
f01002d8:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002db:	89 d8                	mov    %ebx,%eax
f01002dd:	eb 0e                	jmp    f01002ed <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01002df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002e4:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01002e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002ea:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002eb:	89 d8                	mov    %ebx,%eax
}
f01002ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002f0:	c9                   	leave  
f01002f1:	c3                   	ret    

f01002f2 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002f2:	55                   	push   %ebp
f01002f3:	89 e5                	mov    %esp,%ebp
f01002f5:	57                   	push   %edi
f01002f6:	56                   	push   %esi
f01002f7:	53                   	push   %ebx
f01002f8:	83 ec 1c             	sub    $0x1c,%esp
f01002fb:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002fd:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100302:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100307:	b9 84 00 00 00       	mov    $0x84,%ecx
f010030c:	eb 09                	jmp    f0100317 <cons_putc+0x25>
f010030e:	89 ca                	mov    %ecx,%edx
f0100310:	ec                   	in     (%dx),%al
f0100311:	ec                   	in     (%dx),%al
f0100312:	ec                   	in     (%dx),%al
f0100313:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100314:	83 c3 01             	add    $0x1,%ebx
f0100317:	89 f2                	mov    %esi,%edx
f0100319:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010031a:	a8 20                	test   $0x20,%al
f010031c:	75 08                	jne    f0100326 <cons_putc+0x34>
f010031e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100324:	7e e8                	jle    f010030e <cons_putc+0x1c>
f0100326:	89 f8                	mov    %edi,%eax
f0100328:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010032b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100330:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100331:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100336:	be 79 03 00 00       	mov    $0x379,%esi
f010033b:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100340:	eb 09                	jmp    f010034b <cons_putc+0x59>
f0100342:	89 ca                	mov    %ecx,%edx
f0100344:	ec                   	in     (%dx),%al
f0100345:	ec                   	in     (%dx),%al
f0100346:	ec                   	in     (%dx),%al
f0100347:	ec                   	in     (%dx),%al
f0100348:	83 c3 01             	add    $0x1,%ebx
f010034b:	89 f2                	mov    %esi,%edx
f010034d:	ec                   	in     (%dx),%al
f010034e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100354:	7f 04                	jg     f010035a <cons_putc+0x68>
f0100356:	84 c0                	test   %al,%al
f0100358:	79 e8                	jns    f0100342 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010035a:	ba 78 03 00 00       	mov    $0x378,%edx
f010035f:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100363:	ee                   	out    %al,(%dx)
f0100364:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100369:	b8 0d 00 00 00       	mov    $0xd,%eax
f010036e:	ee                   	out    %al,(%dx)
f010036f:	b8 08 00 00 00       	mov    $0x8,%eax
f0100374:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100375:	89 fa                	mov    %edi,%edx
f0100377:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010037d:	89 f8                	mov    %edi,%eax
f010037f:	80 cc 07             	or     $0x7,%ah
f0100382:	85 d2                	test   %edx,%edx
f0100384:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100387:	89 f8                	mov    %edi,%eax
f0100389:	0f b6 c0             	movzbl %al,%eax
f010038c:	83 f8 09             	cmp    $0x9,%eax
f010038f:	74 74                	je     f0100405 <cons_putc+0x113>
f0100391:	83 f8 09             	cmp    $0x9,%eax
f0100394:	7f 0a                	jg     f01003a0 <cons_putc+0xae>
f0100396:	83 f8 08             	cmp    $0x8,%eax
f0100399:	74 14                	je     f01003af <cons_putc+0xbd>
f010039b:	e9 99 00 00 00       	jmp    f0100439 <cons_putc+0x147>
f01003a0:	83 f8 0a             	cmp    $0xa,%eax
f01003a3:	74 3a                	je     f01003df <cons_putc+0xed>
f01003a5:	83 f8 0d             	cmp    $0xd,%eax
f01003a8:	74 3d                	je     f01003e7 <cons_putc+0xf5>
f01003aa:	e9 8a 00 00 00       	jmp    f0100439 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01003af:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003b6:	66 85 c0             	test   %ax,%ax
f01003b9:	0f 84 e6 00 00 00    	je     f01004a5 <cons_putc+0x1b3>
			crt_pos--;
f01003bf:	83 e8 01             	sub    $0x1,%eax
f01003c2:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003c8:	0f b7 c0             	movzwl %ax,%eax
f01003cb:	66 81 e7 00 ff       	and    $0xff00,%di
f01003d0:	83 cf 20             	or     $0x20,%edi
f01003d3:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01003d9:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003dd:	eb 78                	jmp    f0100457 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003df:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f01003e6:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003e7:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003ee:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003f4:	c1 e8 16             	shr    $0x16,%eax
f01003f7:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003fa:	c1 e0 04             	shl    $0x4,%eax
f01003fd:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
f0100403:	eb 52                	jmp    f0100457 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f0100405:	b8 20 00 00 00       	mov    $0x20,%eax
f010040a:	e8 e3 fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f010040f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100414:	e8 d9 fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f0100419:	b8 20 00 00 00       	mov    $0x20,%eax
f010041e:	e8 cf fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f0100423:	b8 20 00 00 00       	mov    $0x20,%eax
f0100428:	e8 c5 fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f010042d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100432:	e8 bb fe ff ff       	call   f01002f2 <cons_putc>
f0100437:	eb 1e                	jmp    f0100457 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100439:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f0100440:	8d 50 01             	lea    0x1(%eax),%edx
f0100443:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f010044a:	0f b7 c0             	movzwl %ax,%eax
f010044d:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100453:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100457:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f010045e:	cf 07 
f0100460:	76 43                	jbe    f01004a5 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100462:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f0100467:	83 ec 04             	sub    $0x4,%esp
f010046a:	68 00 0f 00 00       	push   $0xf00
f010046f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100475:	52                   	push   %edx
f0100476:	50                   	push   %eax
f0100477:	e8 d9 0f 00 00       	call   f0101455 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010047c:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100482:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100488:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010048e:	83 c4 10             	add    $0x10,%esp
f0100491:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100496:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100499:	39 d0                	cmp    %edx,%eax
f010049b:	75 f4                	jne    f0100491 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010049d:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f01004a4:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004a5:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f01004ab:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004b0:	89 ca                	mov    %ecx,%edx
f01004b2:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004b3:	0f b7 1d 28 25 11 f0 	movzwl 0xf0112528,%ebx
f01004ba:	8d 71 01             	lea    0x1(%ecx),%esi
f01004bd:	89 d8                	mov    %ebx,%eax
f01004bf:	66 c1 e8 08          	shr    $0x8,%ax
f01004c3:	89 f2                	mov    %esi,%edx
f01004c5:	ee                   	out    %al,(%dx)
f01004c6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004cb:	89 ca                	mov    %ecx,%edx
f01004cd:	ee                   	out    %al,(%dx)
f01004ce:	89 d8                	mov    %ebx,%eax
f01004d0:	89 f2                	mov    %esi,%edx
f01004d2:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004d6:	5b                   	pop    %ebx
f01004d7:	5e                   	pop    %esi
f01004d8:	5f                   	pop    %edi
f01004d9:	5d                   	pop    %ebp
f01004da:	c3                   	ret    

f01004db <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004db:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f01004e2:	74 11                	je     f01004f5 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004e4:	55                   	push   %ebp
f01004e5:	89 e5                	mov    %esp,%ebp
f01004e7:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004ea:	b8 77 01 10 f0       	mov    $0xf0100177,%eax
f01004ef:	e8 a2 fc ff ff       	call   f0100196 <cons_intr>
}
f01004f4:	c9                   	leave  
f01004f5:	f3 c3                	repz ret 

f01004f7 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004f7:	55                   	push   %ebp
f01004f8:	89 e5                	mov    %esp,%ebp
f01004fa:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004fd:	b8 d9 01 10 f0       	mov    $0xf01001d9,%eax
f0100502:	e8 8f fc ff ff       	call   f0100196 <cons_intr>
}
f0100507:	c9                   	leave  
f0100508:	c3                   	ret    

f0100509 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100509:	55                   	push   %ebp
f010050a:	89 e5                	mov    %esp,%ebp
f010050c:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010050f:	e8 c7 ff ff ff       	call   f01004db <serial_intr>
	kbd_intr();
f0100514:	e8 de ff ff ff       	call   f01004f7 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100519:	a1 20 25 11 f0       	mov    0xf0112520,%eax
f010051e:	3b 05 24 25 11 f0    	cmp    0xf0112524,%eax
f0100524:	74 26                	je     f010054c <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100526:	8d 50 01             	lea    0x1(%eax),%edx
f0100529:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
f010052f:	0f b6 88 20 23 11 f0 	movzbl -0xfeedce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100536:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100538:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010053e:	75 11                	jne    f0100551 <cons_getc+0x48>
			cons.rpos = 0;
f0100540:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f0100547:	00 00 00 
f010054a:	eb 05                	jmp    f0100551 <cons_getc+0x48>
		return c;
	}
	return 0;
f010054c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100551:	c9                   	leave  
f0100552:	c3                   	ret    

f0100553 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100553:	55                   	push   %ebp
f0100554:	89 e5                	mov    %esp,%ebp
f0100556:	57                   	push   %edi
f0100557:	56                   	push   %esi
f0100558:	53                   	push   %ebx
f0100559:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010055c:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100563:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010056a:	5a a5 
	if (*cp != 0xA55A) {
f010056c:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100573:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100577:	74 11                	je     f010058a <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100579:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f0100580:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100583:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100588:	eb 16                	jmp    f01005a0 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010058a:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100591:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f0100598:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010059b:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005a0:	8b 3d 30 25 11 f0    	mov    0xf0112530,%edi
f01005a6:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005ab:	89 fa                	mov    %edi,%edx
f01005ad:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005ae:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b1:	89 da                	mov    %ebx,%edx
f01005b3:	ec                   	in     (%dx),%al
f01005b4:	0f b6 c8             	movzbl %al,%ecx
f01005b7:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005ba:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005bf:	89 fa                	mov    %edi,%edx
f01005c1:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005c2:	89 da                	mov    %ebx,%edx
f01005c4:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005c5:	89 35 2c 25 11 f0    	mov    %esi,0xf011252c
	crt_pos = pos;
f01005cb:	0f b6 c0             	movzbl %al,%eax
f01005ce:	09 c8                	or     %ecx,%eax
f01005d0:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005d6:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005db:	b8 00 00 00 00       	mov    $0x0,%eax
f01005e0:	89 f2                	mov    %esi,%edx
f01005e2:	ee                   	out    %al,(%dx)
f01005e3:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005e8:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005ed:	ee                   	out    %al,(%dx)
f01005ee:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005f3:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005f8:	89 da                	mov    %ebx,%edx
f01005fa:	ee                   	out    %al,(%dx)
f01005fb:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100600:	b8 00 00 00 00       	mov    $0x0,%eax
f0100605:	ee                   	out    %al,(%dx)
f0100606:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010060b:	b8 03 00 00 00       	mov    $0x3,%eax
f0100610:	ee                   	out    %al,(%dx)
f0100611:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100616:	b8 00 00 00 00       	mov    $0x0,%eax
f010061b:	ee                   	out    %al,(%dx)
f010061c:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100621:	b8 01 00 00 00       	mov    $0x1,%eax
f0100626:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100627:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010062c:	ec                   	in     (%dx),%al
f010062d:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010062f:	3c ff                	cmp    $0xff,%al
f0100631:	0f 95 05 34 25 11 f0 	setne  0xf0112534
f0100638:	89 f2                	mov    %esi,%edx
f010063a:	ec                   	in     (%dx),%al
f010063b:	89 da                	mov    %ebx,%edx
f010063d:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010063e:	80 f9 ff             	cmp    $0xff,%cl
f0100641:	75 10                	jne    f0100653 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f0100643:	83 ec 0c             	sub    $0xc,%esp
f0100646:	68 30 19 10 f0       	push   $0xf0101930
f010064b:	e8 1f 03 00 00       	call   f010096f <cprintf>
f0100650:	83 c4 10             	add    $0x10,%esp
}
f0100653:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100656:	5b                   	pop    %ebx
f0100657:	5e                   	pop    %esi
f0100658:	5f                   	pop    %edi
f0100659:	5d                   	pop    %ebp
f010065a:	c3                   	ret    

f010065b <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010065b:	55                   	push   %ebp
f010065c:	89 e5                	mov    %esp,%ebp
f010065e:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100661:	8b 45 08             	mov    0x8(%ebp),%eax
f0100664:	e8 89 fc ff ff       	call   f01002f2 <cons_putc>
}
f0100669:	c9                   	leave  
f010066a:	c3                   	ret    

f010066b <getchar>:

int
getchar(void)
{
f010066b:	55                   	push   %ebp
f010066c:	89 e5                	mov    %esp,%ebp
f010066e:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100671:	e8 93 fe ff ff       	call   f0100509 <cons_getc>
f0100676:	85 c0                	test   %eax,%eax
f0100678:	74 f7                	je     f0100671 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010067a:	c9                   	leave  
f010067b:	c3                   	ret    

f010067c <iscons>:

int
iscons(int fdnum)
{
f010067c:	55                   	push   %ebp
f010067d:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010067f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100684:	5d                   	pop    %ebp
f0100685:	c3                   	ret    

f0100686 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100686:	55                   	push   %ebp
f0100687:	89 e5                	mov    %esp,%ebp
f0100689:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010068c:	68 80 1b 10 f0       	push   $0xf0101b80
f0100691:	68 9e 1b 10 f0       	push   $0xf0101b9e
f0100696:	68 a3 1b 10 f0       	push   $0xf0101ba3
f010069b:	e8 cf 02 00 00       	call   f010096f <cprintf>
f01006a0:	83 c4 0c             	add    $0xc,%esp
f01006a3:	68 40 1c 10 f0       	push   $0xf0101c40
f01006a8:	68 ac 1b 10 f0       	push   $0xf0101bac
f01006ad:	68 a3 1b 10 f0       	push   $0xf0101ba3
f01006b2:	e8 b8 02 00 00       	call   f010096f <cprintf>
f01006b7:	83 c4 0c             	add    $0xc,%esp
f01006ba:	68 b5 1b 10 f0       	push   $0xf0101bb5
f01006bf:	68 c1 1b 10 f0       	push   $0xf0101bc1
f01006c4:	68 a3 1b 10 f0       	push   $0xf0101ba3
f01006c9:	e8 a1 02 00 00       	call   f010096f <cprintf>
	return 0;
}
f01006ce:	b8 00 00 00 00       	mov    $0x0,%eax
f01006d3:	c9                   	leave  
f01006d4:	c3                   	ret    

f01006d5 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006d5:	55                   	push   %ebp
f01006d6:	89 e5                	mov    %esp,%ebp
f01006d8:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006db:	68 cb 1b 10 f0       	push   $0xf0101bcb
f01006e0:	e8 8a 02 00 00       	call   f010096f <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006e5:	83 c4 08             	add    $0x8,%esp
f01006e8:	68 0c 00 10 00       	push   $0x10000c
f01006ed:	68 68 1c 10 f0       	push   $0xf0101c68
f01006f2:	e8 78 02 00 00       	call   f010096f <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006f7:	83 c4 0c             	add    $0xc,%esp
f01006fa:	68 0c 00 10 00       	push   $0x10000c
f01006ff:	68 0c 00 10 f0       	push   $0xf010000c
f0100704:	68 90 1c 10 f0       	push   $0xf0101c90
f0100709:	e8 61 02 00 00       	call   f010096f <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010070e:	83 c4 0c             	add    $0xc,%esp
f0100711:	68 91 18 10 00       	push   $0x101891
f0100716:	68 91 18 10 f0       	push   $0xf0101891
f010071b:	68 b4 1c 10 f0       	push   $0xf0101cb4
f0100720:	e8 4a 02 00 00       	call   f010096f <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100725:	83 c4 0c             	add    $0xc,%esp
f0100728:	68 00 23 11 00       	push   $0x112300
f010072d:	68 00 23 11 f0       	push   $0xf0112300
f0100732:	68 d8 1c 10 f0       	push   $0xf0101cd8
f0100737:	e8 33 02 00 00       	call   f010096f <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010073c:	83 c4 0c             	add    $0xc,%esp
f010073f:	68 44 29 11 00       	push   $0x112944
f0100744:	68 44 29 11 f0       	push   $0xf0112944
f0100749:	68 fc 1c 10 f0       	push   $0xf0101cfc
f010074e:	e8 1c 02 00 00       	call   f010096f <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100753:	b8 43 2d 11 f0       	mov    $0xf0112d43,%eax
f0100758:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010075d:	83 c4 08             	add    $0x8,%esp
f0100760:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100765:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010076b:	85 c0                	test   %eax,%eax
f010076d:	0f 48 c2             	cmovs  %edx,%eax
f0100770:	c1 f8 0a             	sar    $0xa,%eax
f0100773:	50                   	push   %eax
f0100774:	68 20 1d 10 f0       	push   $0xf0101d20
f0100779:	e8 f1 01 00 00       	call   f010096f <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010077e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100783:	c9                   	leave  
f0100784:	c3                   	ret    

f0100785 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100785:	55                   	push   %ebp
f0100786:	89 e5                	mov    %esp,%ebp
f0100788:	57                   	push   %edi
f0100789:	56                   	push   %esi
f010078a:	53                   	push   %ebx
f010078b:	83 ec 38             	sub    $0x38,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010078e:	89 eb                	mov    %ebp,%ebx

             struct Eipdebuginfo eip_dbinfo;

             ebp = read_ebp();

             cprintf("Backtrace: \n");
f0100790:	68 e4 1b 10 f0       	push   $0xf0101be4
f0100795:	e8 d5 01 00 00       	call   f010096f <cprintf>
f010079a:	83 c4 10             	add    $0x10,%esp
                   args[3] = ((uint32_t *)ebp)[5];
                   args[4] = ((uint32_t *)ebp)[6];

               cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n",           eip,ebp,args[0],args[1],args[2],args[3],args[4]);

             if(!debuginfo_eip(eip, &eip_dbinfo))
f010079d:	8d 7d d0             	lea    -0x30(%ebp),%edi

             cprintf("Backtrace: \n");

             do {
                   //first adress after ebp is RET
                   eip = ((uint32_t *)ebp)[1];
f01007a0:	8b 73 04             	mov    0x4(%ebx),%esi
                   args[1] = ((uint32_t *)ebp)[3];
                   args[2] = ((uint32_t *)ebp)[4];
                   args[3] = ((uint32_t *)ebp)[5];
                   args[4] = ((uint32_t *)ebp)[6];

               cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n",           eip,ebp,args[0],args[1],args[2],args[3],args[4]);
f01007a3:	ff 73 18             	pushl  0x18(%ebx)
f01007a6:	ff 73 14             	pushl  0x14(%ebx)
f01007a9:	ff 73 10             	pushl  0x10(%ebx)
f01007ac:	ff 73 0c             	pushl  0xc(%ebx)
f01007af:	ff 73 08             	pushl  0x8(%ebx)
f01007b2:	53                   	push   %ebx
f01007b3:	56                   	push   %esi
f01007b4:	68 4c 1d 10 f0       	push   $0xf0101d4c
f01007b9:	e8 b1 01 00 00       	call   f010096f <cprintf>

             if(!debuginfo_eip(eip, &eip_dbinfo))
f01007be:	83 c4 18             	add    $0x18,%esp
f01007c1:	57                   	push   %edi
f01007c2:	56                   	push   %esi
f01007c3:	e8 b1 02 00 00       	call   f0100a79 <debuginfo_eip>
f01007c8:	83 c4 10             	add    $0x10,%esp
f01007cb:	85 c0                	test   %eax,%eax
f01007cd:	75 20                	jne    f01007ef <mon_backtrace+0x6a>
                   {
                      cprintf("   %s:%d: %.*s+%d\n", eip_dbinfo.eip_file, eip_dbinfo.eip_line,
f01007cf:	83 ec 08             	sub    $0x8,%esp
f01007d2:	2b 75 e0             	sub    -0x20(%ebp),%esi
f01007d5:	56                   	push   %esi
f01007d6:	ff 75 d8             	pushl  -0x28(%ebp)
f01007d9:	ff 75 dc             	pushl  -0x24(%ebp)
f01007dc:	ff 75 d4             	pushl  -0x2c(%ebp)
f01007df:	ff 75 d0             	pushl  -0x30(%ebp)
f01007e2:	68 f1 1b 10 f0       	push   $0xf0101bf1
f01007e7:	e8 83 01 00 00       	call   f010096f <cprintf>
f01007ec:	83 c4 20             	add    $0x20,%esp
                                              eip_dbinfo.eip_fn_namelen, eip_dbinfo.eip_fn_name,
                                              eip - eip_dbinfo.eip_fn_addr);
 
                   }

               ebp = *((uint32_t *) ebp);
f01007ef:	8b 1b                	mov    (%ebx),%ebx
             } while(ebp);
f01007f1:	85 db                	test   %ebx,%ebx
f01007f3:	75 ab                	jne    f01007a0 <mon_backtrace+0x1b>
             
	return 0;
}
f01007f5:	b8 00 00 00 00       	mov    $0x0,%eax
f01007fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007fd:	5b                   	pop    %ebx
f01007fe:	5e                   	pop    %esi
f01007ff:	5f                   	pop    %edi
f0100800:	5d                   	pop    %ebp
f0100801:	c3                   	ret    

f0100802 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100802:	55                   	push   %ebp
f0100803:	89 e5                	mov    %esp,%ebp
f0100805:	57                   	push   %edi
f0100806:	56                   	push   %esi
f0100807:	53                   	push   %ebx
f0100808:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010080b:	68 80 1d 10 f0       	push   $0xf0101d80
f0100810:	e8 5a 01 00 00       	call   f010096f <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100815:	c7 04 24 a4 1d 10 f0 	movl   $0xf0101da4,(%esp)
f010081c:	e8 4e 01 00 00       	call   f010096f <cprintf>
f0100821:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100824:	83 ec 0c             	sub    $0xc,%esp
f0100827:	68 04 1c 10 f0       	push   $0xf0101c04
f010082c:	e8 80 09 00 00       	call   f01011b1 <readline>
f0100831:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100833:	83 c4 10             	add    $0x10,%esp
f0100836:	85 c0                	test   %eax,%eax
f0100838:	74 ea                	je     f0100824 <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010083a:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100841:	be 00 00 00 00       	mov    $0x0,%esi
f0100846:	eb 0a                	jmp    f0100852 <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100848:	c6 03 00             	movb   $0x0,(%ebx)
f010084b:	89 f7                	mov    %esi,%edi
f010084d:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100850:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100852:	0f b6 03             	movzbl (%ebx),%eax
f0100855:	84 c0                	test   %al,%al
f0100857:	74 63                	je     f01008bc <monitor+0xba>
f0100859:	83 ec 08             	sub    $0x8,%esp
f010085c:	0f be c0             	movsbl %al,%eax
f010085f:	50                   	push   %eax
f0100860:	68 08 1c 10 f0       	push   $0xf0101c08
f0100865:	e8 61 0b 00 00       	call   f01013cb <strchr>
f010086a:	83 c4 10             	add    $0x10,%esp
f010086d:	85 c0                	test   %eax,%eax
f010086f:	75 d7                	jne    f0100848 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100871:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100874:	74 46                	je     f01008bc <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100876:	83 fe 0f             	cmp    $0xf,%esi
f0100879:	75 14                	jne    f010088f <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010087b:	83 ec 08             	sub    $0x8,%esp
f010087e:	6a 10                	push   $0x10
f0100880:	68 0d 1c 10 f0       	push   $0xf0101c0d
f0100885:	e8 e5 00 00 00       	call   f010096f <cprintf>
f010088a:	83 c4 10             	add    $0x10,%esp
f010088d:	eb 95                	jmp    f0100824 <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f010088f:	8d 7e 01             	lea    0x1(%esi),%edi
f0100892:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100896:	eb 03                	jmp    f010089b <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100898:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010089b:	0f b6 03             	movzbl (%ebx),%eax
f010089e:	84 c0                	test   %al,%al
f01008a0:	74 ae                	je     f0100850 <monitor+0x4e>
f01008a2:	83 ec 08             	sub    $0x8,%esp
f01008a5:	0f be c0             	movsbl %al,%eax
f01008a8:	50                   	push   %eax
f01008a9:	68 08 1c 10 f0       	push   $0xf0101c08
f01008ae:	e8 18 0b 00 00       	call   f01013cb <strchr>
f01008b3:	83 c4 10             	add    $0x10,%esp
f01008b6:	85 c0                	test   %eax,%eax
f01008b8:	74 de                	je     f0100898 <monitor+0x96>
f01008ba:	eb 94                	jmp    f0100850 <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f01008bc:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008c3:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008c4:	85 f6                	test   %esi,%esi
f01008c6:	0f 84 58 ff ff ff    	je     f0100824 <monitor+0x22>
f01008cc:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008d1:	83 ec 08             	sub    $0x8,%esp
f01008d4:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008d7:	ff 34 85 e0 1d 10 f0 	pushl  -0xfefe220(,%eax,4)
f01008de:	ff 75 a8             	pushl  -0x58(%ebp)
f01008e1:	e8 87 0a 00 00       	call   f010136d <strcmp>
f01008e6:	83 c4 10             	add    $0x10,%esp
f01008e9:	85 c0                	test   %eax,%eax
f01008eb:	75 21                	jne    f010090e <monitor+0x10c>
			return commands[i].func(argc, argv, tf);
f01008ed:	83 ec 04             	sub    $0x4,%esp
f01008f0:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008f3:	ff 75 08             	pushl  0x8(%ebp)
f01008f6:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01008f9:	52                   	push   %edx
f01008fa:	56                   	push   %esi
f01008fb:	ff 14 85 e8 1d 10 f0 	call   *-0xfefe218(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100902:	83 c4 10             	add    $0x10,%esp
f0100905:	85 c0                	test   %eax,%eax
f0100907:	78 25                	js     f010092e <monitor+0x12c>
f0100909:	e9 16 ff ff ff       	jmp    f0100824 <monitor+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f010090e:	83 c3 01             	add    $0x1,%ebx
f0100911:	83 fb 03             	cmp    $0x3,%ebx
f0100914:	75 bb                	jne    f01008d1 <monitor+0xcf>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100916:	83 ec 08             	sub    $0x8,%esp
f0100919:	ff 75 a8             	pushl  -0x58(%ebp)
f010091c:	68 2a 1c 10 f0       	push   $0xf0101c2a
f0100921:	e8 49 00 00 00       	call   f010096f <cprintf>
f0100926:	83 c4 10             	add    $0x10,%esp
f0100929:	e9 f6 fe ff ff       	jmp    f0100824 <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010092e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100931:	5b                   	pop    %ebx
f0100932:	5e                   	pop    %esi
f0100933:	5f                   	pop    %edi
f0100934:	5d                   	pop    %ebp
f0100935:	c3                   	ret    

f0100936 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100936:	55                   	push   %ebp
f0100937:	89 e5                	mov    %esp,%ebp
f0100939:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010093c:	ff 75 08             	pushl  0x8(%ebp)
f010093f:	e8 17 fd ff ff       	call   f010065b <cputchar>
	*cnt++;
}
f0100944:	83 c4 10             	add    $0x10,%esp
f0100947:	c9                   	leave  
f0100948:	c3                   	ret    

f0100949 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100949:	55                   	push   %ebp
f010094a:	89 e5                	mov    %esp,%ebp
f010094c:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010094f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100956:	ff 75 0c             	pushl  0xc(%ebp)
f0100959:	ff 75 08             	pushl  0x8(%ebp)
f010095c:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010095f:	50                   	push   %eax
f0100960:	68 36 09 10 f0       	push   $0xf0100936
f0100965:	e8 32 04 00 00       	call   f0100d9c <vprintfmt>
	return cnt;
}
f010096a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010096d:	c9                   	leave  
f010096e:	c3                   	ret    

f010096f <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010096f:	55                   	push   %ebp
f0100970:	89 e5                	mov    %esp,%ebp
f0100972:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100975:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100978:	50                   	push   %eax
f0100979:	ff 75 08             	pushl  0x8(%ebp)
f010097c:	e8 c8 ff ff ff       	call   f0100949 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100981:	c9                   	leave  
f0100982:	c3                   	ret    

f0100983 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100983:	55                   	push   %ebp
f0100984:	89 e5                	mov    %esp,%ebp
f0100986:	57                   	push   %edi
f0100987:	56                   	push   %esi
f0100988:	53                   	push   %ebx
f0100989:	83 ec 14             	sub    $0x14,%esp
f010098c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010098f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100992:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100995:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100998:	8b 1a                	mov    (%edx),%ebx
f010099a:	8b 01                	mov    (%ecx),%eax
f010099c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010099f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01009a6:	eb 7f                	jmp    f0100a27 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01009a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01009ab:	01 d8                	add    %ebx,%eax
f01009ad:	89 c6                	mov    %eax,%esi
f01009af:	c1 ee 1f             	shr    $0x1f,%esi
f01009b2:	01 c6                	add    %eax,%esi
f01009b4:	d1 fe                	sar    %esi
f01009b6:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01009b9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01009bc:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01009bf:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009c1:	eb 03                	jmp    f01009c6 <stab_binsearch+0x43>
			m--;
f01009c3:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009c6:	39 c3                	cmp    %eax,%ebx
f01009c8:	7f 0d                	jg     f01009d7 <stab_binsearch+0x54>
f01009ca:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01009ce:	83 ea 0c             	sub    $0xc,%edx
f01009d1:	39 f9                	cmp    %edi,%ecx
f01009d3:	75 ee                	jne    f01009c3 <stab_binsearch+0x40>
f01009d5:	eb 05                	jmp    f01009dc <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01009d7:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01009da:	eb 4b                	jmp    f0100a27 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01009dc:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01009df:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01009e2:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01009e6:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01009e9:	76 11                	jbe    f01009fc <stab_binsearch+0x79>
			*region_left = m;
f01009eb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01009ee:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01009f0:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01009f3:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01009fa:	eb 2b                	jmp    f0100a27 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01009fc:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01009ff:	73 14                	jae    f0100a15 <stab_binsearch+0x92>
			*region_right = m - 1;
f0100a01:	83 e8 01             	sub    $0x1,%eax
f0100a04:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a07:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a0a:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a0c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a13:	eb 12                	jmp    f0100a27 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a15:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a18:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100a1a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100a1e:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a20:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100a27:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100a2a:	0f 8e 78 ff ff ff    	jle    f01009a8 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100a30:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100a34:	75 0f                	jne    f0100a45 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0100a36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a39:	8b 00                	mov    (%eax),%eax
f0100a3b:	83 e8 01             	sub    $0x1,%eax
f0100a3e:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a41:	89 06                	mov    %eax,(%esi)
f0100a43:	eb 2c                	jmp    f0100a71 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a45:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a48:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100a4a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a4d:	8b 0e                	mov    (%esi),%ecx
f0100a4f:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a52:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100a55:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a58:	eb 03                	jmp    f0100a5d <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100a5a:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a5d:	39 c8                	cmp    %ecx,%eax
f0100a5f:	7e 0b                	jle    f0100a6c <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0100a61:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0100a65:	83 ea 0c             	sub    $0xc,%edx
f0100a68:	39 df                	cmp    %ebx,%edi
f0100a6a:	75 ee                	jne    f0100a5a <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100a6c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a6f:	89 06                	mov    %eax,(%esi)
	}
}
f0100a71:	83 c4 14             	add    $0x14,%esp
f0100a74:	5b                   	pop    %ebx
f0100a75:	5e                   	pop    %esi
f0100a76:	5f                   	pop    %edi
f0100a77:	5d                   	pop    %ebp
f0100a78:	c3                   	ret    

f0100a79 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100a79:	55                   	push   %ebp
f0100a7a:	89 e5                	mov    %esp,%ebp
f0100a7c:	57                   	push   %edi
f0100a7d:	56                   	push   %esi
f0100a7e:	53                   	push   %ebx
f0100a7f:	83 ec 1c             	sub    $0x1c,%esp
f0100a82:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100a85:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100a88:	c7 06 04 1e 10 f0    	movl   $0xf0101e04,(%esi)
	info->eip_line = 0;
f0100a8e:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100a95:	c7 46 08 04 1e 10 f0 	movl   $0xf0101e04,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100a9c:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100aa3:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100aa6:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100aad:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100ab3:	76 11                	jbe    f0100ac6 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ab5:	b8 ac 72 10 f0       	mov    $0xf01072ac,%eax
f0100aba:	3d 9d 59 10 f0       	cmp    $0xf010599d,%eax
f0100abf:	77 19                	ja     f0100ada <debuginfo_eip+0x61>
f0100ac1:	e9 8a 01 00 00       	jmp    f0100c50 <debuginfo_eip+0x1d7>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100ac6:	83 ec 04             	sub    $0x4,%esp
f0100ac9:	68 0e 1e 10 f0       	push   $0xf0101e0e
f0100ace:	6a 7f                	push   $0x7f
f0100ad0:	68 1b 1e 10 f0       	push   $0xf0101e1b
f0100ad5:	e8 0c f6 ff ff       	call   f01000e6 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ada:	80 3d ab 72 10 f0 00 	cmpb   $0x0,0xf01072ab
f0100ae1:	0f 85 70 01 00 00    	jne    f0100c57 <debuginfo_eip+0x1de>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100ae7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100aee:	b8 9c 59 10 f0       	mov    $0xf010599c,%eax
f0100af3:	2d 3c 20 10 f0       	sub    $0xf010203c,%eax
f0100af8:	c1 f8 02             	sar    $0x2,%eax
f0100afb:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100b01:	83 e8 01             	sub    $0x1,%eax
f0100b04:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100b07:	83 ec 08             	sub    $0x8,%esp
f0100b0a:	57                   	push   %edi
f0100b0b:	6a 64                	push   $0x64
f0100b0d:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100b10:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100b13:	b8 3c 20 10 f0       	mov    $0xf010203c,%eax
f0100b18:	e8 66 fe ff ff       	call   f0100983 <stab_binsearch>
	if (lfile == 0)
f0100b1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b20:	83 c4 10             	add    $0x10,%esp
f0100b23:	85 c0                	test   %eax,%eax
f0100b25:	0f 84 33 01 00 00    	je     f0100c5e <debuginfo_eip+0x1e5>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100b2b:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100b2e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b31:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100b34:	83 ec 08             	sub    $0x8,%esp
f0100b37:	57                   	push   %edi
f0100b38:	6a 24                	push   $0x24
f0100b3a:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100b3d:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b40:	b8 3c 20 10 f0       	mov    $0xf010203c,%eax
f0100b45:	e8 39 fe ff ff       	call   f0100983 <stab_binsearch>

	if (lfun <= rfun) {
f0100b4a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100b4d:	83 c4 10             	add    $0x10,%esp
f0100b50:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0100b53:	7f 47                	jg     f0100b9c <debuginfo_eip+0x123>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100b55:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b58:	c1 e0 02             	shl    $0x2,%eax
f0100b5b:	8d 90 3c 20 10 f0    	lea    -0xfefdfc4(%eax),%edx
f0100b61:	8b 88 3c 20 10 f0    	mov    -0xfefdfc4(%eax),%ecx
f0100b67:	b8 ac 72 10 f0       	mov    $0xf01072ac,%eax
f0100b6c:	2d 9d 59 10 f0       	sub    $0xf010599d,%eax
f0100b71:	39 c1                	cmp    %eax,%ecx
f0100b73:	73 09                	jae    f0100b7e <debuginfo_eip+0x105>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100b75:	81 c1 9d 59 10 f0    	add    $0xf010599d,%ecx
f0100b7b:	89 4e 08             	mov    %ecx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100b7e:	8b 42 08             	mov    0x8(%edx),%eax
f0100b81:	89 46 10             	mov    %eax,0x10(%esi)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100b84:	83 ec 08             	sub    $0x8,%esp
f0100b87:	6a 3a                	push   $0x3a
f0100b89:	ff 76 08             	pushl  0x8(%esi)
f0100b8c:	e8 5b 08 00 00       	call   f01013ec <strfind>
f0100b91:	2b 46 08             	sub    0x8(%esi),%eax
f0100b94:	89 46 0c             	mov    %eax,0xc(%esi)
f0100b97:	83 c4 10             	add    $0x10,%esp
f0100b9a:	eb 27                	jmp    f0100bc3 <debuginfo_eip+0x14a>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100b9c:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100b9f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
f0100ba2:	8b 7d e0             	mov    -0x20(%ebp),%edi
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100ba5:	83 ec 08             	sub    $0x8,%esp
f0100ba8:	6a 3a                	push   $0x3a
f0100baa:	ff 76 08             	pushl  0x8(%esi)
f0100bad:	e8 3a 08 00 00       	call   f01013ec <strfind>
f0100bb2:	2b 46 08             	sub    0x8(%esi),%eax
f0100bb5:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
             if(lline <= rline) {
f0100bb8:	83 c4 10             	add    $0x10,%esp
f0100bbb:	39 fb                	cmp    %edi,%ebx
f0100bbd:	0f 8f a2 00 00 00    	jg     f0100c65 <debuginfo_eip+0x1ec>

                  info->eip_line = stabs[lline].n_desc;
f0100bc3:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100bc6:	8d 04 85 3c 20 10 f0 	lea    -0xfefdfc4(,%eax,4),%eax
f0100bcd:	0f b7 50 06          	movzwl 0x6(%eax),%edx
f0100bd1:	89 56 04             	mov    %edx,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100bd4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100bd7:	eb 06                	jmp    f0100bdf <debuginfo_eip+0x166>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100bd9:	83 eb 01             	sub    $0x1,%ebx
f0100bdc:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100bdf:	39 cb                	cmp    %ecx,%ebx
f0100be1:	7c 34                	jl     f0100c17 <debuginfo_eip+0x19e>
	       && stabs[lline].n_type != N_SOL
f0100be3:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0100be7:	80 fa 84             	cmp    $0x84,%dl
f0100bea:	74 0b                	je     f0100bf7 <debuginfo_eip+0x17e>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100bec:	80 fa 64             	cmp    $0x64,%dl
f0100bef:	75 e8                	jne    f0100bd9 <debuginfo_eip+0x160>
f0100bf1:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100bf5:	74 e2                	je     f0100bd9 <debuginfo_eip+0x160>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100bf7:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100bfa:	8b 14 85 3c 20 10 f0 	mov    -0xfefdfc4(,%eax,4),%edx
f0100c01:	b8 ac 72 10 f0       	mov    $0xf01072ac,%eax
f0100c06:	2d 9d 59 10 f0       	sub    $0xf010599d,%eax
f0100c0b:	39 c2                	cmp    %eax,%edx
f0100c0d:	73 08                	jae    f0100c17 <debuginfo_eip+0x19e>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100c0f:	81 c2 9d 59 10 f0    	add    $0xf010599d,%edx
f0100c15:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c17:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100c1a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c1d:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c22:	39 cb                	cmp    %ecx,%ebx
f0100c24:	7d 4b                	jge    f0100c71 <debuginfo_eip+0x1f8>
		for (lline = lfun + 1;
f0100c26:	8d 53 01             	lea    0x1(%ebx),%edx
f0100c29:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100c2c:	8d 04 85 3c 20 10 f0 	lea    -0xfefdfc4(,%eax,4),%eax
f0100c33:	eb 07                	jmp    f0100c3c <debuginfo_eip+0x1c3>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100c35:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100c39:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100c3c:	39 ca                	cmp    %ecx,%edx
f0100c3e:	74 2c                	je     f0100c6c <debuginfo_eip+0x1f3>
f0100c40:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100c43:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0100c47:	74 ec                	je     f0100c35 <debuginfo_eip+0x1bc>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c49:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c4e:	eb 21                	jmp    f0100c71 <debuginfo_eip+0x1f8>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100c50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c55:	eb 1a                	jmp    f0100c71 <debuginfo_eip+0x1f8>
f0100c57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c5c:	eb 13                	jmp    f0100c71 <debuginfo_eip+0x1f8>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100c5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c63:	eb 0c                	jmp    f0100c71 <debuginfo_eip+0x1f8>
	// Your code here.
             if(lline <= rline) {

                  info->eip_line = stabs[lline].n_desc;

             } else return -1;
f0100c65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c6a:	eb 05                	jmp    f0100c71 <debuginfo_eip+0x1f8>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100c71:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c74:	5b                   	pop    %ebx
f0100c75:	5e                   	pop    %esi
f0100c76:	5f                   	pop    %edi
f0100c77:	5d                   	pop    %ebp
f0100c78:	c3                   	ret    

f0100c79 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100c79:	55                   	push   %ebp
f0100c7a:	89 e5                	mov    %esp,%ebp
f0100c7c:	57                   	push   %edi
f0100c7d:	56                   	push   %esi
f0100c7e:	53                   	push   %ebx
f0100c7f:	83 ec 1c             	sub    $0x1c,%esp
f0100c82:	89 c7                	mov    %eax,%edi
f0100c84:	89 d6                	mov    %edx,%esi
f0100c86:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c89:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100c8c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100c8f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100c92:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100c95:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100c9a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100c9d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100ca0:	39 d3                	cmp    %edx,%ebx
f0100ca2:	72 05                	jb     f0100ca9 <printnum+0x30>
f0100ca4:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100ca7:	77 45                	ja     f0100cee <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100ca9:	83 ec 0c             	sub    $0xc,%esp
f0100cac:	ff 75 18             	pushl  0x18(%ebp)
f0100caf:	8b 45 14             	mov    0x14(%ebp),%eax
f0100cb2:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100cb5:	53                   	push   %ebx
f0100cb6:	ff 75 10             	pushl  0x10(%ebp)
f0100cb9:	83 ec 08             	sub    $0x8,%esp
f0100cbc:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100cbf:	ff 75 e0             	pushl  -0x20(%ebp)
f0100cc2:	ff 75 dc             	pushl  -0x24(%ebp)
f0100cc5:	ff 75 d8             	pushl  -0x28(%ebp)
f0100cc8:	e8 43 09 00 00       	call   f0101610 <__udivdi3>
f0100ccd:	83 c4 18             	add    $0x18,%esp
f0100cd0:	52                   	push   %edx
f0100cd1:	50                   	push   %eax
f0100cd2:	89 f2                	mov    %esi,%edx
f0100cd4:	89 f8                	mov    %edi,%eax
f0100cd6:	e8 9e ff ff ff       	call   f0100c79 <printnum>
f0100cdb:	83 c4 20             	add    $0x20,%esp
f0100cde:	eb 18                	jmp    f0100cf8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100ce0:	83 ec 08             	sub    $0x8,%esp
f0100ce3:	56                   	push   %esi
f0100ce4:	ff 75 18             	pushl  0x18(%ebp)
f0100ce7:	ff d7                	call   *%edi
f0100ce9:	83 c4 10             	add    $0x10,%esp
f0100cec:	eb 03                	jmp    f0100cf1 <printnum+0x78>
f0100cee:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100cf1:	83 eb 01             	sub    $0x1,%ebx
f0100cf4:	85 db                	test   %ebx,%ebx
f0100cf6:	7f e8                	jg     f0100ce0 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100cf8:	83 ec 08             	sub    $0x8,%esp
f0100cfb:	56                   	push   %esi
f0100cfc:	83 ec 04             	sub    $0x4,%esp
f0100cff:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d02:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d05:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d08:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d0b:	e8 30 0a 00 00       	call   f0101740 <__umoddi3>
f0100d10:	83 c4 14             	add    $0x14,%esp
f0100d13:	0f be 80 29 1e 10 f0 	movsbl -0xfefe1d7(%eax),%eax
f0100d1a:	50                   	push   %eax
f0100d1b:	ff d7                	call   *%edi
}
f0100d1d:	83 c4 10             	add    $0x10,%esp
f0100d20:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d23:	5b                   	pop    %ebx
f0100d24:	5e                   	pop    %esi
f0100d25:	5f                   	pop    %edi
f0100d26:	5d                   	pop    %ebp
f0100d27:	c3                   	ret    

f0100d28 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100d28:	55                   	push   %ebp
f0100d29:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100d2b:	83 fa 01             	cmp    $0x1,%edx
f0100d2e:	7e 0e                	jle    f0100d3e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100d30:	8b 10                	mov    (%eax),%edx
f0100d32:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100d35:	89 08                	mov    %ecx,(%eax)
f0100d37:	8b 02                	mov    (%edx),%eax
f0100d39:	8b 52 04             	mov    0x4(%edx),%edx
f0100d3c:	eb 22                	jmp    f0100d60 <getuint+0x38>
	else if (lflag)
f0100d3e:	85 d2                	test   %edx,%edx
f0100d40:	74 10                	je     f0100d52 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100d42:	8b 10                	mov    (%eax),%edx
f0100d44:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d47:	89 08                	mov    %ecx,(%eax)
f0100d49:	8b 02                	mov    (%edx),%eax
f0100d4b:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d50:	eb 0e                	jmp    f0100d60 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100d52:	8b 10                	mov    (%eax),%edx
f0100d54:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d57:	89 08                	mov    %ecx,(%eax)
f0100d59:	8b 02                	mov    (%edx),%eax
f0100d5b:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100d60:	5d                   	pop    %ebp
f0100d61:	c3                   	ret    

f0100d62 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100d62:	55                   	push   %ebp
f0100d63:	89 e5                	mov    %esp,%ebp
f0100d65:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100d68:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100d6c:	8b 10                	mov    (%eax),%edx
f0100d6e:	3b 50 04             	cmp    0x4(%eax),%edx
f0100d71:	73 0a                	jae    f0100d7d <sprintputch+0x1b>
		*b->buf++ = ch;
f0100d73:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100d76:	89 08                	mov    %ecx,(%eax)
f0100d78:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d7b:	88 02                	mov    %al,(%edx)
}
f0100d7d:	5d                   	pop    %ebp
f0100d7e:	c3                   	ret    

f0100d7f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100d7f:	55                   	push   %ebp
f0100d80:	89 e5                	mov    %esp,%ebp
f0100d82:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100d85:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100d88:	50                   	push   %eax
f0100d89:	ff 75 10             	pushl  0x10(%ebp)
f0100d8c:	ff 75 0c             	pushl  0xc(%ebp)
f0100d8f:	ff 75 08             	pushl  0x8(%ebp)
f0100d92:	e8 05 00 00 00       	call   f0100d9c <vprintfmt>
	va_end(ap);
}
f0100d97:	83 c4 10             	add    $0x10,%esp
f0100d9a:	c9                   	leave  
f0100d9b:	c3                   	ret    

f0100d9c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100d9c:	55                   	push   %ebp
f0100d9d:	89 e5                	mov    %esp,%ebp
f0100d9f:	57                   	push   %edi
f0100da0:	56                   	push   %esi
f0100da1:	53                   	push   %ebx
f0100da2:	83 ec 2c             	sub    $0x2c,%esp
f0100da5:	8b 75 08             	mov    0x8(%ebp),%esi
f0100da8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100dab:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100dae:	eb 12                	jmp    f0100dc2 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100db0:	85 c0                	test   %eax,%eax
f0100db2:	0f 84 89 03 00 00    	je     f0101141 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0100db8:	83 ec 08             	sub    $0x8,%esp
f0100dbb:	53                   	push   %ebx
f0100dbc:	50                   	push   %eax
f0100dbd:	ff d6                	call   *%esi
f0100dbf:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100dc2:	83 c7 01             	add    $0x1,%edi
f0100dc5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100dc9:	83 f8 25             	cmp    $0x25,%eax
f0100dcc:	75 e2                	jne    f0100db0 <vprintfmt+0x14>
f0100dce:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100dd2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100dd9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100de0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0100de7:	ba 00 00 00 00       	mov    $0x0,%edx
f0100dec:	eb 07                	jmp    f0100df5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100dee:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100df1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100df5:	8d 47 01             	lea    0x1(%edi),%eax
f0100df8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100dfb:	0f b6 07             	movzbl (%edi),%eax
f0100dfe:	0f b6 c8             	movzbl %al,%ecx
f0100e01:	83 e8 23             	sub    $0x23,%eax
f0100e04:	3c 55                	cmp    $0x55,%al
f0100e06:	0f 87 1a 03 00 00    	ja     f0101126 <vprintfmt+0x38a>
f0100e0c:	0f b6 c0             	movzbl %al,%eax
f0100e0f:	ff 24 85 b8 1e 10 f0 	jmp    *-0xfefe148(,%eax,4)
f0100e16:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100e19:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100e1d:	eb d6                	jmp    f0100df5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e1f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e22:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e27:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100e2a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100e2d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0100e31:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0100e34:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0100e37:	83 fa 09             	cmp    $0x9,%edx
f0100e3a:	77 39                	ja     f0100e75 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100e3c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100e3f:	eb e9                	jmp    f0100e2a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100e41:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e44:	8d 48 04             	lea    0x4(%eax),%ecx
f0100e47:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0100e4a:	8b 00                	mov    (%eax),%eax
f0100e4c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e4f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100e52:	eb 27                	jmp    f0100e7b <vprintfmt+0xdf>
f0100e54:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e57:	85 c0                	test   %eax,%eax
f0100e59:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100e5e:	0f 49 c8             	cmovns %eax,%ecx
f0100e61:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e67:	eb 8c                	jmp    f0100df5 <vprintfmt+0x59>
f0100e69:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100e6c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100e73:	eb 80                	jmp    f0100df5 <vprintfmt+0x59>
f0100e75:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100e78:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0100e7b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100e7f:	0f 89 70 ff ff ff    	jns    f0100df5 <vprintfmt+0x59>
				width = precision, precision = -1;
f0100e85:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100e88:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100e8b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100e92:	e9 5e ff ff ff       	jmp    f0100df5 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100e97:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e9a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100e9d:	e9 53 ff ff ff       	jmp    f0100df5 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100ea2:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ea5:	8d 50 04             	lea    0x4(%eax),%edx
f0100ea8:	89 55 14             	mov    %edx,0x14(%ebp)
f0100eab:	83 ec 08             	sub    $0x8,%esp
f0100eae:	53                   	push   %ebx
f0100eaf:	ff 30                	pushl  (%eax)
f0100eb1:	ff d6                	call   *%esi
			break;
f0100eb3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100eb6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100eb9:	e9 04 ff ff ff       	jmp    f0100dc2 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100ebe:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ec1:	8d 50 04             	lea    0x4(%eax),%edx
f0100ec4:	89 55 14             	mov    %edx,0x14(%ebp)
f0100ec7:	8b 00                	mov    (%eax),%eax
f0100ec9:	99                   	cltd   
f0100eca:	31 d0                	xor    %edx,%eax
f0100ecc:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100ece:	83 f8 06             	cmp    $0x6,%eax
f0100ed1:	7f 0b                	jg     f0100ede <vprintfmt+0x142>
f0100ed3:	8b 14 85 10 20 10 f0 	mov    -0xfefdff0(,%eax,4),%edx
f0100eda:	85 d2                	test   %edx,%edx
f0100edc:	75 18                	jne    f0100ef6 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0100ede:	50                   	push   %eax
f0100edf:	68 41 1e 10 f0       	push   $0xf0101e41
f0100ee4:	53                   	push   %ebx
f0100ee5:	56                   	push   %esi
f0100ee6:	e8 94 fe ff ff       	call   f0100d7f <printfmt>
f0100eeb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100eee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100ef1:	e9 cc fe ff ff       	jmp    f0100dc2 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0100ef6:	52                   	push   %edx
f0100ef7:	68 4a 1e 10 f0       	push   $0xf0101e4a
f0100efc:	53                   	push   %ebx
f0100efd:	56                   	push   %esi
f0100efe:	e8 7c fe ff ff       	call   f0100d7f <printfmt>
f0100f03:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f06:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f09:	e9 b4 fe ff ff       	jmp    f0100dc2 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100f0e:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f11:	8d 50 04             	lea    0x4(%eax),%edx
f0100f14:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f17:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0100f19:	85 ff                	test   %edi,%edi
f0100f1b:	b8 3a 1e 10 f0       	mov    $0xf0101e3a,%eax
f0100f20:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0100f23:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100f27:	0f 8e 94 00 00 00    	jle    f0100fc1 <vprintfmt+0x225>
f0100f2d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100f31:	0f 84 98 00 00 00    	je     f0100fcf <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f37:	83 ec 08             	sub    $0x8,%esp
f0100f3a:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f3d:	57                   	push   %edi
f0100f3e:	e8 5f 03 00 00       	call   f01012a2 <strnlen>
f0100f43:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100f46:	29 c1                	sub    %eax,%ecx
f0100f48:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0100f4b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0100f4e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0100f52:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f55:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100f58:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f5a:	eb 0f                	jmp    f0100f6b <vprintfmt+0x1cf>
					putch(padc, putdat);
f0100f5c:	83 ec 08             	sub    $0x8,%esp
f0100f5f:	53                   	push   %ebx
f0100f60:	ff 75 e0             	pushl  -0x20(%ebp)
f0100f63:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f65:	83 ef 01             	sub    $0x1,%edi
f0100f68:	83 c4 10             	add    $0x10,%esp
f0100f6b:	85 ff                	test   %edi,%edi
f0100f6d:	7f ed                	jg     f0100f5c <vprintfmt+0x1c0>
f0100f6f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100f72:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0100f75:	85 c9                	test   %ecx,%ecx
f0100f77:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f7c:	0f 49 c1             	cmovns %ecx,%eax
f0100f7f:	29 c1                	sub    %eax,%ecx
f0100f81:	89 75 08             	mov    %esi,0x8(%ebp)
f0100f84:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100f87:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100f8a:	89 cb                	mov    %ecx,%ebx
f0100f8c:	eb 4d                	jmp    f0100fdb <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100f8e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100f92:	74 1b                	je     f0100faf <vprintfmt+0x213>
f0100f94:	0f be c0             	movsbl %al,%eax
f0100f97:	83 e8 20             	sub    $0x20,%eax
f0100f9a:	83 f8 5e             	cmp    $0x5e,%eax
f0100f9d:	76 10                	jbe    f0100faf <vprintfmt+0x213>
					putch('?', putdat);
f0100f9f:	83 ec 08             	sub    $0x8,%esp
f0100fa2:	ff 75 0c             	pushl  0xc(%ebp)
f0100fa5:	6a 3f                	push   $0x3f
f0100fa7:	ff 55 08             	call   *0x8(%ebp)
f0100faa:	83 c4 10             	add    $0x10,%esp
f0100fad:	eb 0d                	jmp    f0100fbc <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0100faf:	83 ec 08             	sub    $0x8,%esp
f0100fb2:	ff 75 0c             	pushl  0xc(%ebp)
f0100fb5:	52                   	push   %edx
f0100fb6:	ff 55 08             	call   *0x8(%ebp)
f0100fb9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100fbc:	83 eb 01             	sub    $0x1,%ebx
f0100fbf:	eb 1a                	jmp    f0100fdb <vprintfmt+0x23f>
f0100fc1:	89 75 08             	mov    %esi,0x8(%ebp)
f0100fc4:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100fc7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100fca:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100fcd:	eb 0c                	jmp    f0100fdb <vprintfmt+0x23f>
f0100fcf:	89 75 08             	mov    %esi,0x8(%ebp)
f0100fd2:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100fd5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100fd8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100fdb:	83 c7 01             	add    $0x1,%edi
f0100fde:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100fe2:	0f be d0             	movsbl %al,%edx
f0100fe5:	85 d2                	test   %edx,%edx
f0100fe7:	74 23                	je     f010100c <vprintfmt+0x270>
f0100fe9:	85 f6                	test   %esi,%esi
f0100feb:	78 a1                	js     f0100f8e <vprintfmt+0x1f2>
f0100fed:	83 ee 01             	sub    $0x1,%esi
f0100ff0:	79 9c                	jns    f0100f8e <vprintfmt+0x1f2>
f0100ff2:	89 df                	mov    %ebx,%edi
f0100ff4:	8b 75 08             	mov    0x8(%ebp),%esi
f0100ff7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100ffa:	eb 18                	jmp    f0101014 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0100ffc:	83 ec 08             	sub    $0x8,%esp
f0100fff:	53                   	push   %ebx
f0101000:	6a 20                	push   $0x20
f0101002:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101004:	83 ef 01             	sub    $0x1,%edi
f0101007:	83 c4 10             	add    $0x10,%esp
f010100a:	eb 08                	jmp    f0101014 <vprintfmt+0x278>
f010100c:	89 df                	mov    %ebx,%edi
f010100e:	8b 75 08             	mov    0x8(%ebp),%esi
f0101011:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101014:	85 ff                	test   %edi,%edi
f0101016:	7f e4                	jg     f0100ffc <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101018:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010101b:	e9 a2 fd ff ff       	jmp    f0100dc2 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101020:	83 fa 01             	cmp    $0x1,%edx
f0101023:	7e 16                	jle    f010103b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0101025:	8b 45 14             	mov    0x14(%ebp),%eax
f0101028:	8d 50 08             	lea    0x8(%eax),%edx
f010102b:	89 55 14             	mov    %edx,0x14(%ebp)
f010102e:	8b 50 04             	mov    0x4(%eax),%edx
f0101031:	8b 00                	mov    (%eax),%eax
f0101033:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101036:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101039:	eb 32                	jmp    f010106d <vprintfmt+0x2d1>
	else if (lflag)
f010103b:	85 d2                	test   %edx,%edx
f010103d:	74 18                	je     f0101057 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f010103f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101042:	8d 50 04             	lea    0x4(%eax),%edx
f0101045:	89 55 14             	mov    %edx,0x14(%ebp)
f0101048:	8b 00                	mov    (%eax),%eax
f010104a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010104d:	89 c1                	mov    %eax,%ecx
f010104f:	c1 f9 1f             	sar    $0x1f,%ecx
f0101052:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101055:	eb 16                	jmp    f010106d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0101057:	8b 45 14             	mov    0x14(%ebp),%eax
f010105a:	8d 50 04             	lea    0x4(%eax),%edx
f010105d:	89 55 14             	mov    %edx,0x14(%ebp)
f0101060:	8b 00                	mov    (%eax),%eax
f0101062:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101065:	89 c1                	mov    %eax,%ecx
f0101067:	c1 f9 1f             	sar    $0x1f,%ecx
f010106a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010106d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101070:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0101073:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0101078:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010107c:	79 74                	jns    f01010f2 <vprintfmt+0x356>
				putch('-', putdat);
f010107e:	83 ec 08             	sub    $0x8,%esp
f0101081:	53                   	push   %ebx
f0101082:	6a 2d                	push   $0x2d
f0101084:	ff d6                	call   *%esi
				num = -(long long) num;
f0101086:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101089:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010108c:	f7 d8                	neg    %eax
f010108e:	83 d2 00             	adc    $0x0,%edx
f0101091:	f7 da                	neg    %edx
f0101093:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0101096:	b9 0a 00 00 00       	mov    $0xa,%ecx
f010109b:	eb 55                	jmp    f01010f2 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010109d:	8d 45 14             	lea    0x14(%ebp),%eax
f01010a0:	e8 83 fc ff ff       	call   f0100d28 <getuint>
			base = 10;
f01010a5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01010aa:	eb 46                	jmp    f01010f2 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
                        num = getuint(&ap, lflag);
f01010ac:	8d 45 14             	lea    0x14(%ebp),%eax
f01010af:	e8 74 fc ff ff       	call   f0100d28 <getuint>
                        base = 8;
f01010b4:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
f01010b9:	eb 37                	jmp    f01010f2 <vprintfmt+0x356>
			
			
		// pointer
		case 'p':
			putch('0', putdat);
f01010bb:	83 ec 08             	sub    $0x8,%esp
f01010be:	53                   	push   %ebx
f01010bf:	6a 30                	push   $0x30
f01010c1:	ff d6                	call   *%esi
			putch('x', putdat);
f01010c3:	83 c4 08             	add    $0x8,%esp
f01010c6:	53                   	push   %ebx
f01010c7:	6a 78                	push   $0x78
f01010c9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01010cb:	8b 45 14             	mov    0x14(%ebp),%eax
f01010ce:	8d 50 04             	lea    0x4(%eax),%edx
f01010d1:	89 55 14             	mov    %edx,0x14(%ebp)
			
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01010d4:	8b 00                	mov    (%eax),%eax
f01010d6:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01010db:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01010de:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01010e3:	eb 0d                	jmp    f01010f2 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01010e5:	8d 45 14             	lea    0x14(%ebp),%eax
f01010e8:	e8 3b fc ff ff       	call   f0100d28 <getuint>
			base = 16;
f01010ed:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01010f2:	83 ec 0c             	sub    $0xc,%esp
f01010f5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01010f9:	57                   	push   %edi
f01010fa:	ff 75 e0             	pushl  -0x20(%ebp)
f01010fd:	51                   	push   %ecx
f01010fe:	52                   	push   %edx
f01010ff:	50                   	push   %eax
f0101100:	89 da                	mov    %ebx,%edx
f0101102:	89 f0                	mov    %esi,%eax
f0101104:	e8 70 fb ff ff       	call   f0100c79 <printnum>
			break;
f0101109:	83 c4 20             	add    $0x20,%esp
f010110c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010110f:	e9 ae fc ff ff       	jmp    f0100dc2 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101114:	83 ec 08             	sub    $0x8,%esp
f0101117:	53                   	push   %ebx
f0101118:	51                   	push   %ecx
f0101119:	ff d6                	call   *%esi
			break;
f010111b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010111e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0101121:	e9 9c fc ff ff       	jmp    f0100dc2 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101126:	83 ec 08             	sub    $0x8,%esp
f0101129:	53                   	push   %ebx
f010112a:	6a 25                	push   $0x25
f010112c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010112e:	83 c4 10             	add    $0x10,%esp
f0101131:	eb 03                	jmp    f0101136 <vprintfmt+0x39a>
f0101133:	83 ef 01             	sub    $0x1,%edi
f0101136:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f010113a:	75 f7                	jne    f0101133 <vprintfmt+0x397>
f010113c:	e9 81 fc ff ff       	jmp    f0100dc2 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0101141:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101144:	5b                   	pop    %ebx
f0101145:	5e                   	pop    %esi
f0101146:	5f                   	pop    %edi
f0101147:	5d                   	pop    %ebp
f0101148:	c3                   	ret    

f0101149 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101149:	55                   	push   %ebp
f010114a:	89 e5                	mov    %esp,%ebp
f010114c:	83 ec 18             	sub    $0x18,%esp
f010114f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101152:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101155:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101158:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010115c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010115f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101166:	85 c0                	test   %eax,%eax
f0101168:	74 26                	je     f0101190 <vsnprintf+0x47>
f010116a:	85 d2                	test   %edx,%edx
f010116c:	7e 22                	jle    f0101190 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010116e:	ff 75 14             	pushl  0x14(%ebp)
f0101171:	ff 75 10             	pushl  0x10(%ebp)
f0101174:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101177:	50                   	push   %eax
f0101178:	68 62 0d 10 f0       	push   $0xf0100d62
f010117d:	e8 1a fc ff ff       	call   f0100d9c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101182:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101185:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101188:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010118b:	83 c4 10             	add    $0x10,%esp
f010118e:	eb 05                	jmp    f0101195 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0101190:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101195:	c9                   	leave  
f0101196:	c3                   	ret    

f0101197 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101197:	55                   	push   %ebp
f0101198:	89 e5                	mov    %esp,%ebp
f010119a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010119d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01011a0:	50                   	push   %eax
f01011a1:	ff 75 10             	pushl  0x10(%ebp)
f01011a4:	ff 75 0c             	pushl  0xc(%ebp)
f01011a7:	ff 75 08             	pushl  0x8(%ebp)
f01011aa:	e8 9a ff ff ff       	call   f0101149 <vsnprintf>
	va_end(ap);

	return rc;
}
f01011af:	c9                   	leave  
f01011b0:	c3                   	ret    

f01011b1 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01011b1:	55                   	push   %ebp
f01011b2:	89 e5                	mov    %esp,%ebp
f01011b4:	57                   	push   %edi
f01011b5:	56                   	push   %esi
f01011b6:	53                   	push   %ebx
f01011b7:	83 ec 0c             	sub    $0xc,%esp
f01011ba:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01011bd:	85 c0                	test   %eax,%eax
f01011bf:	74 11                	je     f01011d2 <readline+0x21>
		cprintf("%s", prompt);
f01011c1:	83 ec 08             	sub    $0x8,%esp
f01011c4:	50                   	push   %eax
f01011c5:	68 4a 1e 10 f0       	push   $0xf0101e4a
f01011ca:	e8 a0 f7 ff ff       	call   f010096f <cprintf>
f01011cf:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01011d2:	83 ec 0c             	sub    $0xc,%esp
f01011d5:	6a 00                	push   $0x0
f01011d7:	e8 a0 f4 ff ff       	call   f010067c <iscons>
f01011dc:	89 c7                	mov    %eax,%edi
f01011de:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01011e1:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01011e6:	e8 80 f4 ff ff       	call   f010066b <getchar>
f01011eb:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01011ed:	85 c0                	test   %eax,%eax
f01011ef:	79 18                	jns    f0101209 <readline+0x58>
			cprintf("read error: %e\n", c);
f01011f1:	83 ec 08             	sub    $0x8,%esp
f01011f4:	50                   	push   %eax
f01011f5:	68 2c 20 10 f0       	push   $0xf010202c
f01011fa:	e8 70 f7 ff ff       	call   f010096f <cprintf>
			return NULL;
f01011ff:	83 c4 10             	add    $0x10,%esp
f0101202:	b8 00 00 00 00       	mov    $0x0,%eax
f0101207:	eb 79                	jmp    f0101282 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101209:	83 f8 08             	cmp    $0x8,%eax
f010120c:	0f 94 c2             	sete   %dl
f010120f:	83 f8 7f             	cmp    $0x7f,%eax
f0101212:	0f 94 c0             	sete   %al
f0101215:	08 c2                	or     %al,%dl
f0101217:	74 1a                	je     f0101233 <readline+0x82>
f0101219:	85 f6                	test   %esi,%esi
f010121b:	7e 16                	jle    f0101233 <readline+0x82>
			if (echoing)
f010121d:	85 ff                	test   %edi,%edi
f010121f:	74 0d                	je     f010122e <readline+0x7d>
				cputchar('\b');
f0101221:	83 ec 0c             	sub    $0xc,%esp
f0101224:	6a 08                	push   $0x8
f0101226:	e8 30 f4 ff ff       	call   f010065b <cputchar>
f010122b:	83 c4 10             	add    $0x10,%esp
			i--;
f010122e:	83 ee 01             	sub    $0x1,%esi
f0101231:	eb b3                	jmp    f01011e6 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101233:	83 fb 1f             	cmp    $0x1f,%ebx
f0101236:	7e 23                	jle    f010125b <readline+0xaa>
f0101238:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010123e:	7f 1b                	jg     f010125b <readline+0xaa>
			if (echoing)
f0101240:	85 ff                	test   %edi,%edi
f0101242:	74 0c                	je     f0101250 <readline+0x9f>
				cputchar(c);
f0101244:	83 ec 0c             	sub    $0xc,%esp
f0101247:	53                   	push   %ebx
f0101248:	e8 0e f4 ff ff       	call   f010065b <cputchar>
f010124d:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0101250:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f0101256:	8d 76 01             	lea    0x1(%esi),%esi
f0101259:	eb 8b                	jmp    f01011e6 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f010125b:	83 fb 0a             	cmp    $0xa,%ebx
f010125e:	74 05                	je     f0101265 <readline+0xb4>
f0101260:	83 fb 0d             	cmp    $0xd,%ebx
f0101263:	75 81                	jne    f01011e6 <readline+0x35>
			if (echoing)
f0101265:	85 ff                	test   %edi,%edi
f0101267:	74 0d                	je     f0101276 <readline+0xc5>
				cputchar('\n');
f0101269:	83 ec 0c             	sub    $0xc,%esp
f010126c:	6a 0a                	push   $0xa
f010126e:	e8 e8 f3 ff ff       	call   f010065b <cputchar>
f0101273:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0101276:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f010127d:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f0101282:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101285:	5b                   	pop    %ebx
f0101286:	5e                   	pop    %esi
f0101287:	5f                   	pop    %edi
f0101288:	5d                   	pop    %ebp
f0101289:	c3                   	ret    

f010128a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010128a:	55                   	push   %ebp
f010128b:	89 e5                	mov    %esp,%ebp
f010128d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101290:	b8 00 00 00 00       	mov    $0x0,%eax
f0101295:	eb 03                	jmp    f010129a <strlen+0x10>
		n++;
f0101297:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010129a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010129e:	75 f7                	jne    f0101297 <strlen+0xd>
		n++;
	return n;
}
f01012a0:	5d                   	pop    %ebp
f01012a1:	c3                   	ret    

f01012a2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01012a2:	55                   	push   %ebp
f01012a3:	89 e5                	mov    %esp,%ebp
f01012a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01012a8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01012ab:	ba 00 00 00 00       	mov    $0x0,%edx
f01012b0:	eb 03                	jmp    f01012b5 <strnlen+0x13>
		n++;
f01012b2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01012b5:	39 c2                	cmp    %eax,%edx
f01012b7:	74 08                	je     f01012c1 <strnlen+0x1f>
f01012b9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01012bd:	75 f3                	jne    f01012b2 <strnlen+0x10>
f01012bf:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01012c1:	5d                   	pop    %ebp
f01012c2:	c3                   	ret    

f01012c3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01012c3:	55                   	push   %ebp
f01012c4:	89 e5                	mov    %esp,%ebp
f01012c6:	53                   	push   %ebx
f01012c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01012ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01012cd:	89 c2                	mov    %eax,%edx
f01012cf:	83 c2 01             	add    $0x1,%edx
f01012d2:	83 c1 01             	add    $0x1,%ecx
f01012d5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01012d9:	88 5a ff             	mov    %bl,-0x1(%edx)
f01012dc:	84 db                	test   %bl,%bl
f01012de:	75 ef                	jne    f01012cf <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01012e0:	5b                   	pop    %ebx
f01012e1:	5d                   	pop    %ebp
f01012e2:	c3                   	ret    

f01012e3 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01012e3:	55                   	push   %ebp
f01012e4:	89 e5                	mov    %esp,%ebp
f01012e6:	53                   	push   %ebx
f01012e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01012ea:	53                   	push   %ebx
f01012eb:	e8 9a ff ff ff       	call   f010128a <strlen>
f01012f0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01012f3:	ff 75 0c             	pushl  0xc(%ebp)
f01012f6:	01 d8                	add    %ebx,%eax
f01012f8:	50                   	push   %eax
f01012f9:	e8 c5 ff ff ff       	call   f01012c3 <strcpy>
	return dst;
}
f01012fe:	89 d8                	mov    %ebx,%eax
f0101300:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101303:	c9                   	leave  
f0101304:	c3                   	ret    

f0101305 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101305:	55                   	push   %ebp
f0101306:	89 e5                	mov    %esp,%ebp
f0101308:	56                   	push   %esi
f0101309:	53                   	push   %ebx
f010130a:	8b 75 08             	mov    0x8(%ebp),%esi
f010130d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101310:	89 f3                	mov    %esi,%ebx
f0101312:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101315:	89 f2                	mov    %esi,%edx
f0101317:	eb 0f                	jmp    f0101328 <strncpy+0x23>
		*dst++ = *src;
f0101319:	83 c2 01             	add    $0x1,%edx
f010131c:	0f b6 01             	movzbl (%ecx),%eax
f010131f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101322:	80 39 01             	cmpb   $0x1,(%ecx)
f0101325:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101328:	39 da                	cmp    %ebx,%edx
f010132a:	75 ed                	jne    f0101319 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010132c:	89 f0                	mov    %esi,%eax
f010132e:	5b                   	pop    %ebx
f010132f:	5e                   	pop    %esi
f0101330:	5d                   	pop    %ebp
f0101331:	c3                   	ret    

f0101332 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101332:	55                   	push   %ebp
f0101333:	89 e5                	mov    %esp,%ebp
f0101335:	56                   	push   %esi
f0101336:	53                   	push   %ebx
f0101337:	8b 75 08             	mov    0x8(%ebp),%esi
f010133a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010133d:	8b 55 10             	mov    0x10(%ebp),%edx
f0101340:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101342:	85 d2                	test   %edx,%edx
f0101344:	74 21                	je     f0101367 <strlcpy+0x35>
f0101346:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010134a:	89 f2                	mov    %esi,%edx
f010134c:	eb 09                	jmp    f0101357 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010134e:	83 c2 01             	add    $0x1,%edx
f0101351:	83 c1 01             	add    $0x1,%ecx
f0101354:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101357:	39 c2                	cmp    %eax,%edx
f0101359:	74 09                	je     f0101364 <strlcpy+0x32>
f010135b:	0f b6 19             	movzbl (%ecx),%ebx
f010135e:	84 db                	test   %bl,%bl
f0101360:	75 ec                	jne    f010134e <strlcpy+0x1c>
f0101362:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0101364:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101367:	29 f0                	sub    %esi,%eax
}
f0101369:	5b                   	pop    %ebx
f010136a:	5e                   	pop    %esi
f010136b:	5d                   	pop    %ebp
f010136c:	c3                   	ret    

f010136d <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010136d:	55                   	push   %ebp
f010136e:	89 e5                	mov    %esp,%ebp
f0101370:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101373:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101376:	eb 06                	jmp    f010137e <strcmp+0x11>
		p++, q++;
f0101378:	83 c1 01             	add    $0x1,%ecx
f010137b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010137e:	0f b6 01             	movzbl (%ecx),%eax
f0101381:	84 c0                	test   %al,%al
f0101383:	74 04                	je     f0101389 <strcmp+0x1c>
f0101385:	3a 02                	cmp    (%edx),%al
f0101387:	74 ef                	je     f0101378 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101389:	0f b6 c0             	movzbl %al,%eax
f010138c:	0f b6 12             	movzbl (%edx),%edx
f010138f:	29 d0                	sub    %edx,%eax
}
f0101391:	5d                   	pop    %ebp
f0101392:	c3                   	ret    

f0101393 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101393:	55                   	push   %ebp
f0101394:	89 e5                	mov    %esp,%ebp
f0101396:	53                   	push   %ebx
f0101397:	8b 45 08             	mov    0x8(%ebp),%eax
f010139a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010139d:	89 c3                	mov    %eax,%ebx
f010139f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01013a2:	eb 06                	jmp    f01013aa <strncmp+0x17>
		n--, p++, q++;
f01013a4:	83 c0 01             	add    $0x1,%eax
f01013a7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01013aa:	39 d8                	cmp    %ebx,%eax
f01013ac:	74 15                	je     f01013c3 <strncmp+0x30>
f01013ae:	0f b6 08             	movzbl (%eax),%ecx
f01013b1:	84 c9                	test   %cl,%cl
f01013b3:	74 04                	je     f01013b9 <strncmp+0x26>
f01013b5:	3a 0a                	cmp    (%edx),%cl
f01013b7:	74 eb                	je     f01013a4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01013b9:	0f b6 00             	movzbl (%eax),%eax
f01013bc:	0f b6 12             	movzbl (%edx),%edx
f01013bf:	29 d0                	sub    %edx,%eax
f01013c1:	eb 05                	jmp    f01013c8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01013c3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01013c8:	5b                   	pop    %ebx
f01013c9:	5d                   	pop    %ebp
f01013ca:	c3                   	ret    

f01013cb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01013cb:	55                   	push   %ebp
f01013cc:	89 e5                	mov    %esp,%ebp
f01013ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01013d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01013d5:	eb 07                	jmp    f01013de <strchr+0x13>
		if (*s == c)
f01013d7:	38 ca                	cmp    %cl,%dl
f01013d9:	74 0f                	je     f01013ea <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01013db:	83 c0 01             	add    $0x1,%eax
f01013de:	0f b6 10             	movzbl (%eax),%edx
f01013e1:	84 d2                	test   %dl,%dl
f01013e3:	75 f2                	jne    f01013d7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01013e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01013ea:	5d                   	pop    %ebp
f01013eb:	c3                   	ret    

f01013ec <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01013ec:	55                   	push   %ebp
f01013ed:	89 e5                	mov    %esp,%ebp
f01013ef:	8b 45 08             	mov    0x8(%ebp),%eax
f01013f2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01013f6:	eb 03                	jmp    f01013fb <strfind+0xf>
f01013f8:	83 c0 01             	add    $0x1,%eax
f01013fb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01013fe:	38 ca                	cmp    %cl,%dl
f0101400:	74 04                	je     f0101406 <strfind+0x1a>
f0101402:	84 d2                	test   %dl,%dl
f0101404:	75 f2                	jne    f01013f8 <strfind+0xc>
			break;
	return (char *) s;
}
f0101406:	5d                   	pop    %ebp
f0101407:	c3                   	ret    

f0101408 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101408:	55                   	push   %ebp
f0101409:	89 e5                	mov    %esp,%ebp
f010140b:	57                   	push   %edi
f010140c:	56                   	push   %esi
f010140d:	53                   	push   %ebx
f010140e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101411:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101414:	85 c9                	test   %ecx,%ecx
f0101416:	74 36                	je     f010144e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101418:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010141e:	75 28                	jne    f0101448 <memset+0x40>
f0101420:	f6 c1 03             	test   $0x3,%cl
f0101423:	75 23                	jne    f0101448 <memset+0x40>
		c &= 0xFF;
f0101425:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101429:	89 d3                	mov    %edx,%ebx
f010142b:	c1 e3 08             	shl    $0x8,%ebx
f010142e:	89 d6                	mov    %edx,%esi
f0101430:	c1 e6 18             	shl    $0x18,%esi
f0101433:	89 d0                	mov    %edx,%eax
f0101435:	c1 e0 10             	shl    $0x10,%eax
f0101438:	09 f0                	or     %esi,%eax
f010143a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010143c:	89 d8                	mov    %ebx,%eax
f010143e:	09 d0                	or     %edx,%eax
f0101440:	c1 e9 02             	shr    $0x2,%ecx
f0101443:	fc                   	cld    
f0101444:	f3 ab                	rep stos %eax,%es:(%edi)
f0101446:	eb 06                	jmp    f010144e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101448:	8b 45 0c             	mov    0xc(%ebp),%eax
f010144b:	fc                   	cld    
f010144c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010144e:	89 f8                	mov    %edi,%eax
f0101450:	5b                   	pop    %ebx
f0101451:	5e                   	pop    %esi
f0101452:	5f                   	pop    %edi
f0101453:	5d                   	pop    %ebp
f0101454:	c3                   	ret    

f0101455 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101455:	55                   	push   %ebp
f0101456:	89 e5                	mov    %esp,%ebp
f0101458:	57                   	push   %edi
f0101459:	56                   	push   %esi
f010145a:	8b 45 08             	mov    0x8(%ebp),%eax
f010145d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101460:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101463:	39 c6                	cmp    %eax,%esi
f0101465:	73 35                	jae    f010149c <memmove+0x47>
f0101467:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010146a:	39 d0                	cmp    %edx,%eax
f010146c:	73 2e                	jae    f010149c <memmove+0x47>
		s += n;
		d += n;
f010146e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101471:	89 d6                	mov    %edx,%esi
f0101473:	09 fe                	or     %edi,%esi
f0101475:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010147b:	75 13                	jne    f0101490 <memmove+0x3b>
f010147d:	f6 c1 03             	test   $0x3,%cl
f0101480:	75 0e                	jne    f0101490 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0101482:	83 ef 04             	sub    $0x4,%edi
f0101485:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101488:	c1 e9 02             	shr    $0x2,%ecx
f010148b:	fd                   	std    
f010148c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010148e:	eb 09                	jmp    f0101499 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101490:	83 ef 01             	sub    $0x1,%edi
f0101493:	8d 72 ff             	lea    -0x1(%edx),%esi
f0101496:	fd                   	std    
f0101497:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101499:	fc                   	cld    
f010149a:	eb 1d                	jmp    f01014b9 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010149c:	89 f2                	mov    %esi,%edx
f010149e:	09 c2                	or     %eax,%edx
f01014a0:	f6 c2 03             	test   $0x3,%dl
f01014a3:	75 0f                	jne    f01014b4 <memmove+0x5f>
f01014a5:	f6 c1 03             	test   $0x3,%cl
f01014a8:	75 0a                	jne    f01014b4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01014aa:	c1 e9 02             	shr    $0x2,%ecx
f01014ad:	89 c7                	mov    %eax,%edi
f01014af:	fc                   	cld    
f01014b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01014b2:	eb 05                	jmp    f01014b9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01014b4:	89 c7                	mov    %eax,%edi
f01014b6:	fc                   	cld    
f01014b7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01014b9:	5e                   	pop    %esi
f01014ba:	5f                   	pop    %edi
f01014bb:	5d                   	pop    %ebp
f01014bc:	c3                   	ret    

f01014bd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01014bd:	55                   	push   %ebp
f01014be:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01014c0:	ff 75 10             	pushl  0x10(%ebp)
f01014c3:	ff 75 0c             	pushl  0xc(%ebp)
f01014c6:	ff 75 08             	pushl  0x8(%ebp)
f01014c9:	e8 87 ff ff ff       	call   f0101455 <memmove>
}
f01014ce:	c9                   	leave  
f01014cf:	c3                   	ret    

f01014d0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01014d0:	55                   	push   %ebp
f01014d1:	89 e5                	mov    %esp,%ebp
f01014d3:	56                   	push   %esi
f01014d4:	53                   	push   %ebx
f01014d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01014d8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01014db:	89 c6                	mov    %eax,%esi
f01014dd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01014e0:	eb 1a                	jmp    f01014fc <memcmp+0x2c>
		if (*s1 != *s2)
f01014e2:	0f b6 08             	movzbl (%eax),%ecx
f01014e5:	0f b6 1a             	movzbl (%edx),%ebx
f01014e8:	38 d9                	cmp    %bl,%cl
f01014ea:	74 0a                	je     f01014f6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01014ec:	0f b6 c1             	movzbl %cl,%eax
f01014ef:	0f b6 db             	movzbl %bl,%ebx
f01014f2:	29 d8                	sub    %ebx,%eax
f01014f4:	eb 0f                	jmp    f0101505 <memcmp+0x35>
		s1++, s2++;
f01014f6:	83 c0 01             	add    $0x1,%eax
f01014f9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01014fc:	39 f0                	cmp    %esi,%eax
f01014fe:	75 e2                	jne    f01014e2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0101500:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101505:	5b                   	pop    %ebx
f0101506:	5e                   	pop    %esi
f0101507:	5d                   	pop    %ebp
f0101508:	c3                   	ret    

f0101509 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101509:	55                   	push   %ebp
f010150a:	89 e5                	mov    %esp,%ebp
f010150c:	53                   	push   %ebx
f010150d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0101510:	89 c1                	mov    %eax,%ecx
f0101512:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0101515:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101519:	eb 0a                	jmp    f0101525 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010151b:	0f b6 10             	movzbl (%eax),%edx
f010151e:	39 da                	cmp    %ebx,%edx
f0101520:	74 07                	je     f0101529 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101522:	83 c0 01             	add    $0x1,%eax
f0101525:	39 c8                	cmp    %ecx,%eax
f0101527:	72 f2                	jb     f010151b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101529:	5b                   	pop    %ebx
f010152a:	5d                   	pop    %ebp
f010152b:	c3                   	ret    

f010152c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010152c:	55                   	push   %ebp
f010152d:	89 e5                	mov    %esp,%ebp
f010152f:	57                   	push   %edi
f0101530:	56                   	push   %esi
f0101531:	53                   	push   %ebx
f0101532:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101535:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101538:	eb 03                	jmp    f010153d <strtol+0x11>
		s++;
f010153a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010153d:	0f b6 01             	movzbl (%ecx),%eax
f0101540:	3c 20                	cmp    $0x20,%al
f0101542:	74 f6                	je     f010153a <strtol+0xe>
f0101544:	3c 09                	cmp    $0x9,%al
f0101546:	74 f2                	je     f010153a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101548:	3c 2b                	cmp    $0x2b,%al
f010154a:	75 0a                	jne    f0101556 <strtol+0x2a>
		s++;
f010154c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010154f:	bf 00 00 00 00       	mov    $0x0,%edi
f0101554:	eb 11                	jmp    f0101567 <strtol+0x3b>
f0101556:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010155b:	3c 2d                	cmp    $0x2d,%al
f010155d:	75 08                	jne    f0101567 <strtol+0x3b>
		s++, neg = 1;
f010155f:	83 c1 01             	add    $0x1,%ecx
f0101562:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101567:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010156d:	75 15                	jne    f0101584 <strtol+0x58>
f010156f:	80 39 30             	cmpb   $0x30,(%ecx)
f0101572:	75 10                	jne    f0101584 <strtol+0x58>
f0101574:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101578:	75 7c                	jne    f01015f6 <strtol+0xca>
		s += 2, base = 16;
f010157a:	83 c1 02             	add    $0x2,%ecx
f010157d:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101582:	eb 16                	jmp    f010159a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0101584:	85 db                	test   %ebx,%ebx
f0101586:	75 12                	jne    f010159a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101588:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010158d:	80 39 30             	cmpb   $0x30,(%ecx)
f0101590:	75 08                	jne    f010159a <strtol+0x6e>
		s++, base = 8;
f0101592:	83 c1 01             	add    $0x1,%ecx
f0101595:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010159a:	b8 00 00 00 00       	mov    $0x0,%eax
f010159f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01015a2:	0f b6 11             	movzbl (%ecx),%edx
f01015a5:	8d 72 d0             	lea    -0x30(%edx),%esi
f01015a8:	89 f3                	mov    %esi,%ebx
f01015aa:	80 fb 09             	cmp    $0x9,%bl
f01015ad:	77 08                	ja     f01015b7 <strtol+0x8b>
			dig = *s - '0';
f01015af:	0f be d2             	movsbl %dl,%edx
f01015b2:	83 ea 30             	sub    $0x30,%edx
f01015b5:	eb 22                	jmp    f01015d9 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01015b7:	8d 72 9f             	lea    -0x61(%edx),%esi
f01015ba:	89 f3                	mov    %esi,%ebx
f01015bc:	80 fb 19             	cmp    $0x19,%bl
f01015bf:	77 08                	ja     f01015c9 <strtol+0x9d>
			dig = *s - 'a' + 10;
f01015c1:	0f be d2             	movsbl %dl,%edx
f01015c4:	83 ea 57             	sub    $0x57,%edx
f01015c7:	eb 10                	jmp    f01015d9 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01015c9:	8d 72 bf             	lea    -0x41(%edx),%esi
f01015cc:	89 f3                	mov    %esi,%ebx
f01015ce:	80 fb 19             	cmp    $0x19,%bl
f01015d1:	77 16                	ja     f01015e9 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01015d3:	0f be d2             	movsbl %dl,%edx
f01015d6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01015d9:	3b 55 10             	cmp    0x10(%ebp),%edx
f01015dc:	7d 0b                	jge    f01015e9 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01015de:	83 c1 01             	add    $0x1,%ecx
f01015e1:	0f af 45 10          	imul   0x10(%ebp),%eax
f01015e5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01015e7:	eb b9                	jmp    f01015a2 <strtol+0x76>

	if (endptr)
f01015e9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01015ed:	74 0d                	je     f01015fc <strtol+0xd0>
		*endptr = (char *) s;
f01015ef:	8b 75 0c             	mov    0xc(%ebp),%esi
f01015f2:	89 0e                	mov    %ecx,(%esi)
f01015f4:	eb 06                	jmp    f01015fc <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01015f6:	85 db                	test   %ebx,%ebx
f01015f8:	74 98                	je     f0101592 <strtol+0x66>
f01015fa:	eb 9e                	jmp    f010159a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01015fc:	89 c2                	mov    %eax,%edx
f01015fe:	f7 da                	neg    %edx
f0101600:	85 ff                	test   %edi,%edi
f0101602:	0f 45 c2             	cmovne %edx,%eax
}
f0101605:	5b                   	pop    %ebx
f0101606:	5e                   	pop    %esi
f0101607:	5f                   	pop    %edi
f0101608:	5d                   	pop    %ebp
f0101609:	c3                   	ret    
f010160a:	66 90                	xchg   %ax,%ax
f010160c:	66 90                	xchg   %ax,%ax
f010160e:	66 90                	xchg   %ax,%ax

f0101610 <__udivdi3>:
f0101610:	55                   	push   %ebp
f0101611:	57                   	push   %edi
f0101612:	56                   	push   %esi
f0101613:	53                   	push   %ebx
f0101614:	83 ec 1c             	sub    $0x1c,%esp
f0101617:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010161b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010161f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0101623:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101627:	85 f6                	test   %esi,%esi
f0101629:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010162d:	89 ca                	mov    %ecx,%edx
f010162f:	89 f8                	mov    %edi,%eax
f0101631:	75 3d                	jne    f0101670 <__udivdi3+0x60>
f0101633:	39 cf                	cmp    %ecx,%edi
f0101635:	0f 87 c5 00 00 00    	ja     f0101700 <__udivdi3+0xf0>
f010163b:	85 ff                	test   %edi,%edi
f010163d:	89 fd                	mov    %edi,%ebp
f010163f:	75 0b                	jne    f010164c <__udivdi3+0x3c>
f0101641:	b8 01 00 00 00       	mov    $0x1,%eax
f0101646:	31 d2                	xor    %edx,%edx
f0101648:	f7 f7                	div    %edi
f010164a:	89 c5                	mov    %eax,%ebp
f010164c:	89 c8                	mov    %ecx,%eax
f010164e:	31 d2                	xor    %edx,%edx
f0101650:	f7 f5                	div    %ebp
f0101652:	89 c1                	mov    %eax,%ecx
f0101654:	89 d8                	mov    %ebx,%eax
f0101656:	89 cf                	mov    %ecx,%edi
f0101658:	f7 f5                	div    %ebp
f010165a:	89 c3                	mov    %eax,%ebx
f010165c:	89 d8                	mov    %ebx,%eax
f010165e:	89 fa                	mov    %edi,%edx
f0101660:	83 c4 1c             	add    $0x1c,%esp
f0101663:	5b                   	pop    %ebx
f0101664:	5e                   	pop    %esi
f0101665:	5f                   	pop    %edi
f0101666:	5d                   	pop    %ebp
f0101667:	c3                   	ret    
f0101668:	90                   	nop
f0101669:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101670:	39 ce                	cmp    %ecx,%esi
f0101672:	77 74                	ja     f01016e8 <__udivdi3+0xd8>
f0101674:	0f bd fe             	bsr    %esi,%edi
f0101677:	83 f7 1f             	xor    $0x1f,%edi
f010167a:	0f 84 98 00 00 00    	je     f0101718 <__udivdi3+0x108>
f0101680:	bb 20 00 00 00       	mov    $0x20,%ebx
f0101685:	89 f9                	mov    %edi,%ecx
f0101687:	89 c5                	mov    %eax,%ebp
f0101689:	29 fb                	sub    %edi,%ebx
f010168b:	d3 e6                	shl    %cl,%esi
f010168d:	89 d9                	mov    %ebx,%ecx
f010168f:	d3 ed                	shr    %cl,%ebp
f0101691:	89 f9                	mov    %edi,%ecx
f0101693:	d3 e0                	shl    %cl,%eax
f0101695:	09 ee                	or     %ebp,%esi
f0101697:	89 d9                	mov    %ebx,%ecx
f0101699:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010169d:	89 d5                	mov    %edx,%ebp
f010169f:	8b 44 24 08          	mov    0x8(%esp),%eax
f01016a3:	d3 ed                	shr    %cl,%ebp
f01016a5:	89 f9                	mov    %edi,%ecx
f01016a7:	d3 e2                	shl    %cl,%edx
f01016a9:	89 d9                	mov    %ebx,%ecx
f01016ab:	d3 e8                	shr    %cl,%eax
f01016ad:	09 c2                	or     %eax,%edx
f01016af:	89 d0                	mov    %edx,%eax
f01016b1:	89 ea                	mov    %ebp,%edx
f01016b3:	f7 f6                	div    %esi
f01016b5:	89 d5                	mov    %edx,%ebp
f01016b7:	89 c3                	mov    %eax,%ebx
f01016b9:	f7 64 24 0c          	mull   0xc(%esp)
f01016bd:	39 d5                	cmp    %edx,%ebp
f01016bf:	72 10                	jb     f01016d1 <__udivdi3+0xc1>
f01016c1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01016c5:	89 f9                	mov    %edi,%ecx
f01016c7:	d3 e6                	shl    %cl,%esi
f01016c9:	39 c6                	cmp    %eax,%esi
f01016cb:	73 07                	jae    f01016d4 <__udivdi3+0xc4>
f01016cd:	39 d5                	cmp    %edx,%ebp
f01016cf:	75 03                	jne    f01016d4 <__udivdi3+0xc4>
f01016d1:	83 eb 01             	sub    $0x1,%ebx
f01016d4:	31 ff                	xor    %edi,%edi
f01016d6:	89 d8                	mov    %ebx,%eax
f01016d8:	89 fa                	mov    %edi,%edx
f01016da:	83 c4 1c             	add    $0x1c,%esp
f01016dd:	5b                   	pop    %ebx
f01016de:	5e                   	pop    %esi
f01016df:	5f                   	pop    %edi
f01016e0:	5d                   	pop    %ebp
f01016e1:	c3                   	ret    
f01016e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01016e8:	31 ff                	xor    %edi,%edi
f01016ea:	31 db                	xor    %ebx,%ebx
f01016ec:	89 d8                	mov    %ebx,%eax
f01016ee:	89 fa                	mov    %edi,%edx
f01016f0:	83 c4 1c             	add    $0x1c,%esp
f01016f3:	5b                   	pop    %ebx
f01016f4:	5e                   	pop    %esi
f01016f5:	5f                   	pop    %edi
f01016f6:	5d                   	pop    %ebp
f01016f7:	c3                   	ret    
f01016f8:	90                   	nop
f01016f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101700:	89 d8                	mov    %ebx,%eax
f0101702:	f7 f7                	div    %edi
f0101704:	31 ff                	xor    %edi,%edi
f0101706:	89 c3                	mov    %eax,%ebx
f0101708:	89 d8                	mov    %ebx,%eax
f010170a:	89 fa                	mov    %edi,%edx
f010170c:	83 c4 1c             	add    $0x1c,%esp
f010170f:	5b                   	pop    %ebx
f0101710:	5e                   	pop    %esi
f0101711:	5f                   	pop    %edi
f0101712:	5d                   	pop    %ebp
f0101713:	c3                   	ret    
f0101714:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101718:	39 ce                	cmp    %ecx,%esi
f010171a:	72 0c                	jb     f0101728 <__udivdi3+0x118>
f010171c:	31 db                	xor    %ebx,%ebx
f010171e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0101722:	0f 87 34 ff ff ff    	ja     f010165c <__udivdi3+0x4c>
f0101728:	bb 01 00 00 00       	mov    $0x1,%ebx
f010172d:	e9 2a ff ff ff       	jmp    f010165c <__udivdi3+0x4c>
f0101732:	66 90                	xchg   %ax,%ax
f0101734:	66 90                	xchg   %ax,%ax
f0101736:	66 90                	xchg   %ax,%ax
f0101738:	66 90                	xchg   %ax,%ax
f010173a:	66 90                	xchg   %ax,%ax
f010173c:	66 90                	xchg   %ax,%ax
f010173e:	66 90                	xchg   %ax,%ax

f0101740 <__umoddi3>:
f0101740:	55                   	push   %ebp
f0101741:	57                   	push   %edi
f0101742:	56                   	push   %esi
f0101743:	53                   	push   %ebx
f0101744:	83 ec 1c             	sub    $0x1c,%esp
f0101747:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010174b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010174f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101753:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101757:	85 d2                	test   %edx,%edx
f0101759:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010175d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101761:	89 f3                	mov    %esi,%ebx
f0101763:	89 3c 24             	mov    %edi,(%esp)
f0101766:	89 74 24 04          	mov    %esi,0x4(%esp)
f010176a:	75 1c                	jne    f0101788 <__umoddi3+0x48>
f010176c:	39 f7                	cmp    %esi,%edi
f010176e:	76 50                	jbe    f01017c0 <__umoddi3+0x80>
f0101770:	89 c8                	mov    %ecx,%eax
f0101772:	89 f2                	mov    %esi,%edx
f0101774:	f7 f7                	div    %edi
f0101776:	89 d0                	mov    %edx,%eax
f0101778:	31 d2                	xor    %edx,%edx
f010177a:	83 c4 1c             	add    $0x1c,%esp
f010177d:	5b                   	pop    %ebx
f010177e:	5e                   	pop    %esi
f010177f:	5f                   	pop    %edi
f0101780:	5d                   	pop    %ebp
f0101781:	c3                   	ret    
f0101782:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101788:	39 f2                	cmp    %esi,%edx
f010178a:	89 d0                	mov    %edx,%eax
f010178c:	77 52                	ja     f01017e0 <__umoddi3+0xa0>
f010178e:	0f bd ea             	bsr    %edx,%ebp
f0101791:	83 f5 1f             	xor    $0x1f,%ebp
f0101794:	75 5a                	jne    f01017f0 <__umoddi3+0xb0>
f0101796:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010179a:	0f 82 e0 00 00 00    	jb     f0101880 <__umoddi3+0x140>
f01017a0:	39 0c 24             	cmp    %ecx,(%esp)
f01017a3:	0f 86 d7 00 00 00    	jbe    f0101880 <__umoddi3+0x140>
f01017a9:	8b 44 24 08          	mov    0x8(%esp),%eax
f01017ad:	8b 54 24 04          	mov    0x4(%esp),%edx
f01017b1:	83 c4 1c             	add    $0x1c,%esp
f01017b4:	5b                   	pop    %ebx
f01017b5:	5e                   	pop    %esi
f01017b6:	5f                   	pop    %edi
f01017b7:	5d                   	pop    %ebp
f01017b8:	c3                   	ret    
f01017b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01017c0:	85 ff                	test   %edi,%edi
f01017c2:	89 fd                	mov    %edi,%ebp
f01017c4:	75 0b                	jne    f01017d1 <__umoddi3+0x91>
f01017c6:	b8 01 00 00 00       	mov    $0x1,%eax
f01017cb:	31 d2                	xor    %edx,%edx
f01017cd:	f7 f7                	div    %edi
f01017cf:	89 c5                	mov    %eax,%ebp
f01017d1:	89 f0                	mov    %esi,%eax
f01017d3:	31 d2                	xor    %edx,%edx
f01017d5:	f7 f5                	div    %ebp
f01017d7:	89 c8                	mov    %ecx,%eax
f01017d9:	f7 f5                	div    %ebp
f01017db:	89 d0                	mov    %edx,%eax
f01017dd:	eb 99                	jmp    f0101778 <__umoddi3+0x38>
f01017df:	90                   	nop
f01017e0:	89 c8                	mov    %ecx,%eax
f01017e2:	89 f2                	mov    %esi,%edx
f01017e4:	83 c4 1c             	add    $0x1c,%esp
f01017e7:	5b                   	pop    %ebx
f01017e8:	5e                   	pop    %esi
f01017e9:	5f                   	pop    %edi
f01017ea:	5d                   	pop    %ebp
f01017eb:	c3                   	ret    
f01017ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01017f0:	8b 34 24             	mov    (%esp),%esi
f01017f3:	bf 20 00 00 00       	mov    $0x20,%edi
f01017f8:	89 e9                	mov    %ebp,%ecx
f01017fa:	29 ef                	sub    %ebp,%edi
f01017fc:	d3 e0                	shl    %cl,%eax
f01017fe:	89 f9                	mov    %edi,%ecx
f0101800:	89 f2                	mov    %esi,%edx
f0101802:	d3 ea                	shr    %cl,%edx
f0101804:	89 e9                	mov    %ebp,%ecx
f0101806:	09 c2                	or     %eax,%edx
f0101808:	89 d8                	mov    %ebx,%eax
f010180a:	89 14 24             	mov    %edx,(%esp)
f010180d:	89 f2                	mov    %esi,%edx
f010180f:	d3 e2                	shl    %cl,%edx
f0101811:	89 f9                	mov    %edi,%ecx
f0101813:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101817:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010181b:	d3 e8                	shr    %cl,%eax
f010181d:	89 e9                	mov    %ebp,%ecx
f010181f:	89 c6                	mov    %eax,%esi
f0101821:	d3 e3                	shl    %cl,%ebx
f0101823:	89 f9                	mov    %edi,%ecx
f0101825:	89 d0                	mov    %edx,%eax
f0101827:	d3 e8                	shr    %cl,%eax
f0101829:	89 e9                	mov    %ebp,%ecx
f010182b:	09 d8                	or     %ebx,%eax
f010182d:	89 d3                	mov    %edx,%ebx
f010182f:	89 f2                	mov    %esi,%edx
f0101831:	f7 34 24             	divl   (%esp)
f0101834:	89 d6                	mov    %edx,%esi
f0101836:	d3 e3                	shl    %cl,%ebx
f0101838:	f7 64 24 04          	mull   0x4(%esp)
f010183c:	39 d6                	cmp    %edx,%esi
f010183e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101842:	89 d1                	mov    %edx,%ecx
f0101844:	89 c3                	mov    %eax,%ebx
f0101846:	72 08                	jb     f0101850 <__umoddi3+0x110>
f0101848:	75 11                	jne    f010185b <__umoddi3+0x11b>
f010184a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010184e:	73 0b                	jae    f010185b <__umoddi3+0x11b>
f0101850:	2b 44 24 04          	sub    0x4(%esp),%eax
f0101854:	1b 14 24             	sbb    (%esp),%edx
f0101857:	89 d1                	mov    %edx,%ecx
f0101859:	89 c3                	mov    %eax,%ebx
f010185b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010185f:	29 da                	sub    %ebx,%edx
f0101861:	19 ce                	sbb    %ecx,%esi
f0101863:	89 f9                	mov    %edi,%ecx
f0101865:	89 f0                	mov    %esi,%eax
f0101867:	d3 e0                	shl    %cl,%eax
f0101869:	89 e9                	mov    %ebp,%ecx
f010186b:	d3 ea                	shr    %cl,%edx
f010186d:	89 e9                	mov    %ebp,%ecx
f010186f:	d3 ee                	shr    %cl,%esi
f0101871:	09 d0                	or     %edx,%eax
f0101873:	89 f2                	mov    %esi,%edx
f0101875:	83 c4 1c             	add    $0x1c,%esp
f0101878:	5b                   	pop    %ebx
f0101879:	5e                   	pop    %esi
f010187a:	5f                   	pop    %edi
f010187b:	5d                   	pop    %ebp
f010187c:	c3                   	ret    
f010187d:	8d 76 00             	lea    0x0(%esi),%esi
f0101880:	29 f9                	sub    %edi,%ecx
f0101882:	19 d6                	sbb    %edx,%esi
f0101884:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101888:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010188c:	e9 18 ff ff ff       	jmp    f01017a9 <__umoddi3+0x69>
