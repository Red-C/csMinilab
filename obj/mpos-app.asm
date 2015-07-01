
obj/mpos-app:     file format elf32-i386


Disassembly of section .text:

00200000 <app_printf>:

static void app_printf(const char *format, ...) __attribute__((noinline));

static void
app_printf(const char *format, ...)
{
  200000:	83 ec 1c             	sub    $0x1c,%esp
	// That means that after the "asm" instruction (which causes the
	// interrupt), the system call's return value is in the 'pid'
	// variable, and we can just return that value!

	pid_t pid;
	asm volatile("int %1\n"
  200003:	cd 30                	int    $0x30
static void
app_printf(const char *format, ...)
{
	// set default color based on currently running process
	int color = sys_getpid();
	if (color < 0)
  200005:	85 c0                	test   %eax,%eax
  200007:	78 15                	js     20001e <app_printf+0x1e>
		color = 0x0700;
	else {
		static const uint8_t col[] = { 0x0E, 0x0F, 0x0C, 0x0A, 0x09 };
		color = col[color % sizeof(col)] << 8;
  200009:	b9 05 00 00 00       	mov    $0x5,%ecx
  20000e:	31 d2                	xor    %edx,%edx
  200010:	f7 f1                	div    %ecx
  200012:	0f b6 82 9c 06 20 00 	movzbl 0x20069c(%edx),%eax
  200019:	c1 e0 08             	shl    $0x8,%eax
  20001c:	eb 05                	jmp    200023 <app_printf+0x23>
app_printf(const char *format, ...)
{
	// set default color based on currently running process
	int color = sys_getpid();
	if (color < 0)
		color = 0x0700;
  20001e:	b8 00 07 00 00       	mov    $0x700,%eax
		color = col[color % sizeof(col)] << 8;
	}

	va_list val;
	va_start(val, format);
	cursorpos = console_vprintf(cursorpos, color, format, val);
  200023:	8d 54 24 24          	lea    0x24(%esp),%edx
  200027:	89 54 24 0c          	mov    %edx,0xc(%esp)
  20002b:	8b 54 24 20          	mov    0x20(%esp),%edx
  20002f:	89 44 24 04          	mov    %eax,0x4(%esp)
  200033:	a1 00 00 06 00       	mov    0x60000,%eax
  200038:	89 54 24 08          	mov    %edx,0x8(%esp)
  20003c:	89 04 24             	mov    %eax,(%esp)
  20003f:	e8 e9 01 00 00       	call   20022d <console_vprintf>
  200044:	a3 00 00 06 00       	mov    %eax,0x60000
	va_end(val);
}
  200049:	83 c4 1c             	add    $0x1c,%esp
  20004c:	c3                   	ret    

0020004d <run_child>:
	}
}

void
run_child(void)
{
  20004d:	83 ec 2c             	sub    $0x2c,%esp
	int i;
	volatile int checker = 1; /* This variable checks that you correctly
  200050:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  200057:	00 
	// That means that after the "asm" instruction (which causes the
	// interrupt), the system call's return value is in the 'pid'
	// variable, and we can just return that value!

	pid_t pid;
	asm volatile("int %1\n"
  200058:	cd 30                	int    $0x30
				     gave this process a new stack.
				     If the parent's 'checker' changed value
				     after the child ran, there's a problem! */

	app_printf("Child process %d!\n", sys_getpid());
  20005a:	89 44 24 04          	mov    %eax,0x4(%esp)
  20005e:	c7 04 24 14 06 20 00 	movl   $0x200614,(%esp)
  200065:	e8 96 ff ff ff       	call   200000 <app_printf>
  20006a:	b8 14 00 00 00       	mov    $0x14,%eax

static inline void
sys_yield(void)
{
	// This system call has no return values, so there's no '=a' clause.
	asm volatile("int %0\n"
  20006f:	cd 32                	int    $0x32

	// Yield a couple times to help people test Exercise 3
	for (i = 0; i < 20; i++)
  200071:	48                   	dec    %eax
  200072:	75 fb                	jne    20006f <run_child+0x22>
	// the 'int' instruction.
	// You can load other registers with similar syntax; specifically:
	//	"a" = %eax, "b" = %ebx, "c" = %ecx, "d" = %edx,
	//	"S" = %esi, "D" = %edi.

	asm volatile("int %0\n"
  200074:	b8 e8 03 00 00       	mov    $0x3e8,%eax
  200079:	cd 33                	int    $0x33
  20007b:	eb fe                	jmp    20007b <run_child+0x2e>

0020007d <start>:

void run_child(void);

void
start(void)
{
  20007d:	53                   	push   %ebx
  20007e:	83 ec 28             	sub    $0x28,%esp
	volatile int checker = 0; /* This variable checks that you correctly
				     gave the child process a new stack. */
	pid_t p;
	int status;

	app_printf("About to start a new process...\n");
  200081:	c7 04 24 27 06 20 00 	movl   $0x200627,(%esp)
void run_child(void);

void
start(void)
{
	volatile int checker = 0; /* This variable checks that you correctly
  200088:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
  20008f:	00 
				     gave the child process a new stack. */
	pid_t p;
	int status;

	app_printf("About to start a new process...\n");
  200090:	e8 6b ff ff ff       	call   200000 <app_printf>
sys_fork(void)
{
	// This system call follows the same pattern as sys_getpid().

	pid_t result;
	asm volatile("int %1\n"
  200095:	cd 31                	int    $0x31

	p = sys_fork();
	if (p == 0)
  200097:	83 f8 00             	cmp    $0x0,%eax
  20009a:	89 c3                	mov    %eax,%ebx
  20009c:	75 05                	jne    2000a3 <start+0x26>
		run_child();
  20009e:	e8 aa ff ff ff       	call   20004d <run_child>
	else if (p > 0) {
  2000a3:	7e 52                	jle    2000f7 <start+0x7a>
	// That means that after the "asm" instruction (which causes the
	// interrupt), the system call's return value is in the 'pid'
	// variable, and we can just return that value!

	pid_t pid;
	asm volatile("int %1\n"
  2000a5:	cd 30                	int    $0x30
		app_printf("Main process %d!\n", sys_getpid());
  2000a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  2000ab:	c7 04 24 48 06 20 00 	movl   $0x200648,(%esp)
  2000b2:	e8 49 ff ff ff       	call   200000 <app_printf>

static inline int
sys_wait(pid_t pid)
{
	int retval;
	asm volatile("int %1\n"
  2000b7:	89 d8                	mov    %ebx,%eax
  2000b9:	cd 34                	int    $0x34
		do {
			status = sys_wait(p);
		} while (status == WAIT_TRYAGAIN);
  2000bb:	83 f8 fe             	cmp    $0xfffffffe,%eax
  2000be:	74 f7                	je     2000b7 <start+0x3a>
		app_printf("Child %d exited with status %d!\n", p, status);
  2000c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  2000c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  2000c8:	c7 04 24 5a 06 20 00 	movl   $0x20065a,(%esp)
  2000cf:	e8 2c ff ff ff       	call   200000 <app_printf>

		// Check whether the child process corrupted our stack.
		// (This check doesn't find all errors, but it helps.)
		if (checker != 0) {
  2000d4:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  2000d8:	85 c0                	test   %eax,%eax
  2000da:	74 15                	je     2000f1 <start+0x74>
			app_printf("Error: stack collision!\n");
  2000dc:	c7 04 24 7b 06 20 00 	movl   $0x20067b,(%esp)
  2000e3:	e8 18 ff ff ff       	call   200000 <app_printf>
	// the 'int' instruction.
	// You can load other registers with similar syntax; specifically:
	//	"a" = %eax, "b" = %ebx, "c" = %ecx, "d" = %edx,
	//	"S" = %esi, "D" = %edi.

	asm volatile("int %0\n"
  2000e8:	b8 01 00 00 00       	mov    $0x1,%eax
  2000ed:	cd 33                	int    $0x33
  2000ef:	eb fe                	jmp    2000ef <start+0x72>
  2000f1:	31 c0                	xor    %eax,%eax
  2000f3:	cd 33                	int    $0x33
  2000f5:	eb fe                	jmp    2000f5 <start+0x78>
			sys_exit(1);
		} else
			sys_exit(0);

	} else {
		app_printf("Error!\n");
  2000f7:	c7 04 24 94 06 20 00 	movl   $0x200694,(%esp)
  2000fe:	e8 fd fe ff ff       	call   200000 <app_printf>
  200103:	b8 01 00 00 00       	mov    $0x1,%eax
  200108:	cd 33                	int    $0x33
  20010a:	eb fe                	jmp    20010a <start+0x8d>

0020010c <console_putc>:
 *
 *   Print a message onto the console, starting at the given cursor position. */

static uint16_t *
console_putc(uint16_t *cursor, unsigned char c, int color)
{
  20010c:	56                   	push   %esi
	if (cursor >= CONSOLE_END)
		cursor = CONSOLE_BEGIN;
  20010d:	3d a0 8f 0b 00       	cmp    $0xb8fa0,%eax
 *
 *   Print a message onto the console, starting at the given cursor position. */

static uint16_t *
console_putc(uint16_t *cursor, unsigned char c, int color)
{
  200112:	53                   	push   %ebx
  200113:	89 c3                	mov    %eax,%ebx
	if (cursor >= CONSOLE_END)
		cursor = CONSOLE_BEGIN;
  200115:	b8 00 80 0b 00       	mov    $0xb8000,%eax
  20011a:	0f 43 d8             	cmovae %eax,%ebx
	if (c == '\n') {
  20011d:	80 fa 0a             	cmp    $0xa,%dl
  200120:	75 2c                	jne    20014e <console_putc+0x42>
		int pos = (cursor - CONSOLE_BEGIN) % 80;
  200122:	8d 83 00 80 f4 ff    	lea    -0xb8000(%ebx),%eax
  200128:	be 50 00 00 00       	mov    $0x50,%esi
  20012d:	d1 f8                	sar    %eax
		for (; pos != 80; pos++)
			*cursor++ = ' ' | color;
  20012f:	83 c9 20             	or     $0x20,%ecx
console_putc(uint16_t *cursor, unsigned char c, int color)
{
	if (cursor >= CONSOLE_END)
		cursor = CONSOLE_BEGIN;
	if (c == '\n') {
		int pos = (cursor - CONSOLE_BEGIN) % 80;
  200132:	99                   	cltd   
  200133:	f7 fe                	idiv   %esi
  200135:	6b c2 fe             	imul   $0xfffffffe,%edx,%eax
  200138:	8d 34 03             	lea    (%ebx,%eax,1),%esi
		for (; pos != 80; pos++)
			*cursor++ = ' ' | color;
  20013b:	66 89 0c 56          	mov    %cx,(%esi,%edx,2)
{
	if (cursor >= CONSOLE_END)
		cursor = CONSOLE_BEGIN;
	if (c == '\n') {
		int pos = (cursor - CONSOLE_BEGIN) % 80;
		for (; pos != 80; pos++)
  20013f:	42                   	inc    %edx
  200140:	83 fa 50             	cmp    $0x50,%edx
  200143:	75 f6                	jne    20013b <console_putc+0x2f>
  200145:	8d 84 03 a0 00 00 00 	lea    0xa0(%ebx,%eax,1),%eax
  20014c:	eb 08                	jmp    200156 <console_putc+0x4a>
			*cursor++ = ' ' | color;
	} else
		*cursor++ = c | color;
  20014e:	09 d1                	or     %edx,%ecx
  200150:	8d 43 02             	lea    0x2(%ebx),%eax
  200153:	66 89 0b             	mov    %cx,(%ebx)
	return cursor;
}
  200156:	5b                   	pop    %ebx
  200157:	5e                   	pop    %esi
  200158:	c3                   	ret    

00200159 <fill_numbuf>:
static const char lower_digits[] = "0123456789abcdef";

static char *
fill_numbuf(char *numbuf_end, uint32_t val, int base, const char *digits,
	    int precision)
{
  200159:	56                   	push   %esi
  20015a:	53                   	push   %ebx
  20015b:	8b 74 24 0c          	mov    0xc(%esp),%esi
	*--numbuf_end = '\0';
	if (precision != 0 || val != 0)
  20015f:	83 7c 24 10 00       	cmpl   $0x0,0x10(%esp)

static char *
fill_numbuf(char *numbuf_end, uint32_t val, int base, const char *digits,
	    int precision)
{
	*--numbuf_end = '\0';
  200164:	8d 58 ff             	lea    -0x1(%eax),%ebx
  200167:	c6 40 ff 00          	movb   $0x0,-0x1(%eax)
	if (precision != 0 || val != 0)
  20016b:	75 04                	jne    200171 <fill_numbuf+0x18>
  20016d:	85 d2                	test   %edx,%edx
  20016f:	74 10                	je     200181 <fill_numbuf+0x28>
		do {
			*--numbuf_end = digits[val % base];
  200171:	89 d0                	mov    %edx,%eax
  200173:	31 d2                	xor    %edx,%edx
  200175:	f7 f1                	div    %ecx
  200177:	4b                   	dec    %ebx
  200178:	8a 14 16             	mov    (%esi,%edx,1),%dl
  20017b:	88 13                	mov    %dl,(%ebx)
			val /= base;
  20017d:	89 c2                	mov    %eax,%edx
  20017f:	eb ec                	jmp    20016d <fill_numbuf+0x14>
		} while (val != 0);
	return numbuf_end;
}
  200181:	89 d8                	mov    %ebx,%eax
  200183:	5b                   	pop    %ebx
  200184:	5e                   	pop    %esi
  200185:	c3                   	ret    

00200186 <memcpy>:
 *
 *   We must provide our own implementations of these basic functions. */

void *
memcpy(void *dst, const void *src, size_t n)
{
  200186:	53                   	push   %ebx
  200187:	8b 44 24 08          	mov    0x8(%esp),%eax
	const char *s = (const char *) src;
	char *d = (char *) dst;
	while (n-- > 0)
  20018b:	31 d2                	xor    %edx,%edx
 *
 *   We must provide our own implementations of these basic functions. */

void *
memcpy(void *dst, const void *src, size_t n)
{
  20018d:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
	const char *s = (const char *) src;
	char *d = (char *) dst;
	while (n-- > 0)
  200191:	3b 54 24 10          	cmp    0x10(%esp),%edx
  200195:	74 09                	je     2001a0 <memcpy+0x1a>
		*d++ = *s++;
  200197:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  20019a:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  20019d:	42                   	inc    %edx
  20019e:	eb f1                	jmp    200191 <memcpy+0xb>
	return dst;
}
  2001a0:	5b                   	pop    %ebx
  2001a1:	c3                   	ret    

002001a2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  2001a2:	55                   	push   %ebp
  2001a3:	57                   	push   %edi
  2001a4:	56                   	push   %esi
  2001a5:	53                   	push   %ebx
  2001a6:	8b 44 24 14          	mov    0x14(%esp),%eax
  2001aa:	8b 5c 24 18          	mov    0x18(%esp),%ebx
  2001ae:	8b 6c 24 1c          	mov    0x1c(%esp),%ebp
	const char *s = (const char *) src;
	char *d = (char *) dst;
	if (s < d && s + n > d) {
  2001b2:	39 c3                	cmp    %eax,%ebx
  2001b4:	72 04                	jb     2001ba <memmove+0x18>
		s += n, d += n;
		while (n-- > 0)
  2001b6:	31 c9                	xor    %ecx,%ecx
  2001b8:	eb 24                	jmp    2001de <memmove+0x3c>
void *
memmove(void *dst, const void *src, size_t n)
{
	const char *s = (const char *) src;
	char *d = (char *) dst;
	if (s < d && s + n > d) {
  2001ba:	8d 34 2b             	lea    (%ebx,%ebp,1),%esi
  2001bd:	39 c6                	cmp    %eax,%esi
  2001bf:	76 f5                	jbe    2001b6 <memmove+0x14>
  2001c1:	89 e9                	mov    %ebp,%ecx
		s += n, d += n;
		while (n-- > 0)
  2001c3:	89 ea                	mov    %ebp,%edx
  2001c5:	f7 d9                	neg    %ecx
memmove(void *dst, const void *src, size_t n)
{
	const char *s = (const char *) src;
	char *d = (char *) dst;
	if (s < d && s + n > d) {
		s += n, d += n;
  2001c7:	8d 3c 28             	lea    (%eax,%ebp,1),%edi
  2001ca:	01 ce                	add    %ecx,%esi
		while (n-- > 0)
  2001cc:	4a                   	dec    %edx
  2001cd:	83 fa ff             	cmp    $0xffffffff,%edx
  2001d0:	74 19                	je     2001eb <memmove+0x49>
			*--d = *--s;
  2001d2:	8a 1c 16             	mov    (%esi,%edx,1),%bl
  2001d5:	8d 2c 0f             	lea    (%edi,%ecx,1),%ebp
  2001d8:	88 5c 15 00          	mov    %bl,0x0(%ebp,%edx,1)
  2001dc:	eb ee                	jmp    2001cc <memmove+0x2a>
	} else
		while (n-- > 0)
  2001de:	39 e9                	cmp    %ebp,%ecx
  2001e0:	74 09                	je     2001eb <memmove+0x49>
			*d++ = *s++;
  2001e2:	8a 14 0b             	mov    (%ebx,%ecx,1),%dl
  2001e5:	88 14 08             	mov    %dl,(%eax,%ecx,1)
  2001e8:	41                   	inc    %ecx
  2001e9:	eb f3                	jmp    2001de <memmove+0x3c>
	return dst;
}
  2001eb:	5b                   	pop    %ebx
  2001ec:	5e                   	pop    %esi
  2001ed:	5f                   	pop    %edi
  2001ee:	5d                   	pop    %ebp
  2001ef:	c3                   	ret    

002001f0 <memset>:

void *
memset(void *v, int c, size_t n)
{
  2001f0:	8b 44 24 04          	mov    0x4(%esp),%eax
	char *p = (char *) v;
	while (n-- > 0)
  2001f4:	31 d2                	xor    %edx,%edx
	return dst;
}

void *
memset(void *v, int c, size_t n)
{
  2001f6:	8b 4c 24 08          	mov    0x8(%esp),%ecx
	char *p = (char *) v;
	while (n-- > 0)
  2001fa:	3b 54 24 0c          	cmp    0xc(%esp),%edx
  2001fe:	74 06                	je     200206 <memset+0x16>
		*p++ = c;
  200200:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  200203:	42                   	inc    %edx
  200204:	eb f4                	jmp    2001fa <memset+0xa>
	return v;
}
  200206:	c3                   	ret    

00200207 <strlen>:

size_t
strlen(const char *s)
{
  200207:	8b 54 24 04          	mov    0x4(%esp),%edx
	size_t n;
	for (n = 0; *s != '\0'; ++s)
  20020b:	31 c0                	xor    %eax,%eax
  20020d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  200211:	74 03                	je     200216 <strlen+0xf>
		++n;
  200213:	40                   	inc    %eax
  200214:	eb f7                	jmp    20020d <strlen+0x6>
	return n;
}
  200216:	c3                   	ret    

00200217 <strnlen>:

size_t
strnlen(const char *s, size_t maxlen)
{
  200217:	8b 54 24 04          	mov    0x4(%esp),%edx
	size_t n;
	for (n = 0; n != maxlen && *s != '\0'; ++s)
  20021b:	31 c0                	xor    %eax,%eax
  20021d:	3b 44 24 08          	cmp    0x8(%esp),%eax
  200221:	74 09                	je     20022c <strnlen+0x15>
  200223:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  200227:	74 03                	je     20022c <strnlen+0x15>
		++n;
  200229:	40                   	inc    %eax
  20022a:	eb f1                	jmp    20021d <strnlen+0x6>
	return n;
}
  20022c:	c3                   	ret    

0020022d <console_vprintf>:
#define FLAG_PLUSPOSITIVE	(1<<4)
static const char flag_chars[] = "#0- +";

uint16_t *
console_vprintf(uint16_t *cursor, int color, const char *format, va_list val)
{
  20022d:	55                   	push   %ebp
  20022e:	57                   	push   %edi
  20022f:	56                   	push   %esi
  200230:	53                   	push   %ebx
  200231:	83 ec 3c             	sub    $0x3c,%esp
  200234:	8b 6c 24 50          	mov    0x50(%esp),%ebp
  200238:	8b 5c 24 5c          	mov    0x5c(%esp),%ebx
	int flags, width, zeros, precision, negative, numeric, len;
#define NUMBUFSIZ 20
	char numbuf[NUMBUFSIZ];
	char *data;

	for (; *format; ++format) {
  20023c:	8b 44 24 58          	mov    0x58(%esp),%eax
  200240:	0f b6 10             	movzbl (%eax),%edx
  200243:	84 d2                	test   %dl,%dl
  200245:	0f 84 94 03 00 00    	je     2005df <console_vprintf+0x3b2>
		if (*format != '%') {
  20024b:	80 fa 25             	cmp    $0x25,%dl
  20024e:	74 12                	je     200262 <console_vprintf+0x35>
			cursor = console_putc(cursor, *format, color);
  200250:	8b 4c 24 54          	mov    0x54(%esp),%ecx
  200254:	89 e8                	mov    %ebp,%eax
  200256:	e8 b1 fe ff ff       	call   20010c <console_putc>
  20025b:	89 c5                	mov    %eax,%ebp
			continue;
  20025d:	e9 5d 03 00 00       	jmp    2005bf <console_vprintf+0x392>
		}

		// process flags
		flags = 0;
		for (++format; *format; ++format) {
  200262:	ff 44 24 58          	incl   0x58(%esp)
			const char *flagc = flag_chars;
			while (*flagc != '\0' && *flagc != *format)
				++flagc;
			if (*flagc == '\0')
				break;
			flags |= (1 << (flagc - flag_chars));
  200266:	be 01 00 00 00       	mov    $0x1,%esi
			cursor = console_putc(cursor, *format, color);
			continue;
		}

		// process flags
		flags = 0;
  20026b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  200272:	00 
		for (++format; *format; ++format) {
  200273:	8b 44 24 58          	mov    0x58(%esp),%eax
  200277:	8a 00                	mov    (%eax),%al
  200279:	84 c0                	test   %al,%al
  20027b:	74 16                	je     200293 <console_vprintf+0x66>
  20027d:	b9 a4 06 20 00       	mov    $0x2006a4,%ecx
			const char *flagc = flag_chars;
			while (*flagc != '\0' && *flagc != *format)
  200282:	8a 11                	mov    (%ecx),%dl
  200284:	84 d2                	test   %dl,%dl
  200286:	74 0b                	je     200293 <console_vprintf+0x66>
  200288:	38 c2                	cmp    %al,%dl
  20028a:	0f 84 38 03 00 00    	je     2005c8 <console_vprintf+0x39b>
				++flagc;
  200290:	41                   	inc    %ecx
  200291:	eb ef                	jmp    200282 <console_vprintf+0x55>
			flags |= (1 << (flagc - flag_chars));
		}

		// process width
		width = -1;
		if (*format >= '1' && *format <= '9') {
  200293:	8d 50 cf             	lea    -0x31(%eax),%edx
  200296:	80 fa 08             	cmp    $0x8,%dl
  200299:	77 2a                	ja     2002c5 <console_vprintf+0x98>
  20029b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  2002a2:	00 
			for (width = 0; *format >= '0' && *format <= '9'; )
  2002a3:	8b 44 24 58          	mov    0x58(%esp),%eax
  2002a7:	0f be 00             	movsbl (%eax),%eax
  2002aa:	8d 50 d0             	lea    -0x30(%eax),%edx
  2002ad:	80 fa 09             	cmp    $0x9,%dl
  2002b0:	77 2c                	ja     2002de <console_vprintf+0xb1>
				width = 10 * width + *format++ - '0';
  2002b2:	6b 74 24 0c 0a       	imul   $0xa,0xc(%esp),%esi
  2002b7:	ff 44 24 58          	incl   0x58(%esp)
  2002bb:	8d 44 06 d0          	lea    -0x30(%esi,%eax,1),%eax
  2002bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  2002c3:	eb de                	jmp    2002a3 <console_vprintf+0x76>
		} else if (*format == '*') {
  2002c5:	3c 2a                	cmp    $0x2a,%al
				break;
			flags |= (1 << (flagc - flag_chars));
		}

		// process width
		width = -1;
  2002c7:	c7 44 24 0c ff ff ff 	movl   $0xffffffff,0xc(%esp)
  2002ce:	ff 
		if (*format >= '1' && *format <= '9') {
			for (width = 0; *format >= '0' && *format <= '9'; )
				width = 10 * width + *format++ - '0';
		} else if (*format == '*') {
  2002cf:	75 0d                	jne    2002de <console_vprintf+0xb1>
			width = va_arg(val, int);
  2002d1:	8b 03                	mov    (%ebx),%eax
  2002d3:	83 c3 04             	add    $0x4,%ebx
			++format;
  2002d6:	ff 44 24 58          	incl   0x58(%esp)
		width = -1;
		if (*format >= '1' && *format <= '9') {
			for (width = 0; *format >= '0' && *format <= '9'; )
				width = 10 * width + *format++ - '0';
		} else if (*format == '*') {
			width = va_arg(val, int);
  2002da:	89 44 24 0c          	mov    %eax,0xc(%esp)
			++format;
		}

		// process precision
		precision = -1;
		if (*format == '.') {
  2002de:	8b 44 24 58          	mov    0x58(%esp),%eax
			width = va_arg(val, int);
			++format;
		}

		// process precision
		precision = -1;
  2002e2:	83 ce ff             	or     $0xffffffff,%esi
		if (*format == '.') {
  2002e5:	80 38 2e             	cmpb   $0x2e,(%eax)
  2002e8:	75 4f                	jne    200339 <console_vprintf+0x10c>
			++format;
			if (*format >= '0' && *format <= '9') {
  2002ea:	8b 7c 24 58          	mov    0x58(%esp),%edi
		}

		// process precision
		precision = -1;
		if (*format == '.') {
			++format;
  2002ee:	40                   	inc    %eax
			if (*format >= '0' && *format <= '9') {
  2002ef:	8a 57 01             	mov    0x1(%edi),%dl
  2002f2:	8d 4a d0             	lea    -0x30(%edx),%ecx
  2002f5:	80 f9 09             	cmp    $0x9,%cl
  2002f8:	77 22                	ja     20031c <console_vprintf+0xef>
  2002fa:	89 44 24 58          	mov    %eax,0x58(%esp)
  2002fe:	31 f6                	xor    %esi,%esi
				for (precision = 0; *format >= '0' && *format <= '9'; )
  200300:	8b 44 24 58          	mov    0x58(%esp),%eax
  200304:	0f be 00             	movsbl (%eax),%eax
  200307:	8d 50 d0             	lea    -0x30(%eax),%edx
  20030a:	80 fa 09             	cmp    $0x9,%dl
  20030d:	77 2a                	ja     200339 <console_vprintf+0x10c>
					precision = 10 * precision + *format++ - '0';
  20030f:	6b f6 0a             	imul   $0xa,%esi,%esi
  200312:	ff 44 24 58          	incl   0x58(%esp)
  200316:	8d 74 06 d0          	lea    -0x30(%esi,%eax,1),%esi
  20031a:	eb e4                	jmp    200300 <console_vprintf+0xd3>
			} else if (*format == '*') {
  20031c:	80 fa 2a             	cmp    $0x2a,%dl
  20031f:	75 12                	jne    200333 <console_vprintf+0x106>
				precision = va_arg(val, int);
  200321:	8b 33                	mov    (%ebx),%esi
  200323:	8d 43 04             	lea    0x4(%ebx),%eax
				++format;
  200326:	83 44 24 58 02       	addl   $0x2,0x58(%esp)
			++format;
			if (*format >= '0' && *format <= '9') {
				for (precision = 0; *format >= '0' && *format <= '9'; )
					precision = 10 * precision + *format++ - '0';
			} else if (*format == '*') {
				precision = va_arg(val, int);
  20032b:	89 c3                	mov    %eax,%ebx
				++format;
			}
			if (precision < 0)
  20032d:	85 f6                	test   %esi,%esi
  20032f:	79 08                	jns    200339 <console_vprintf+0x10c>
  200331:	eb 04                	jmp    200337 <console_vprintf+0x10a>
		}

		// process precision
		precision = -1;
		if (*format == '.') {
			++format;
  200333:	89 44 24 58          	mov    %eax,0x58(%esp)
			} else if (*format == '*') {
				precision = va_arg(val, int);
				++format;
			}
			if (precision < 0)
				precision = 0;
  200337:	31 f6                	xor    %esi,%esi
		}

		// process main conversion character
		negative = 0;
		numeric = 0;
		switch (*format) {
  200339:	8b 44 24 58          	mov    0x58(%esp),%eax
  20033d:	8a 00                	mov    (%eax),%al
  20033f:	3c 64                	cmp    $0x64,%al
  200341:	74 46                	je     200389 <console_vprintf+0x15c>
  200343:	7f 26                	jg     20036b <console_vprintf+0x13e>
  200345:	3c 58                	cmp    $0x58,%al
  200347:	0f 84 9f 00 00 00    	je     2003ec <console_vprintf+0x1bf>
  20034d:	3c 63                	cmp    $0x63,%al
  20034f:	0f 84 c2 00 00 00    	je     200417 <console_vprintf+0x1ea>
  200355:	3c 43                	cmp    $0x43,%al
  200357:	0f 85 ca 00 00 00    	jne    200427 <console_vprintf+0x1fa>
		}
		case 's':
			data = va_arg(val, char *);
			break;
		case 'C':
			color = va_arg(val, int);
  20035d:	8b 03                	mov    (%ebx),%eax
  20035f:	83 c3 04             	add    $0x4,%ebx
  200362:	89 44 24 54          	mov    %eax,0x54(%esp)
			goto done;
  200366:	e9 54 02 00 00       	jmp    2005bf <console_vprintf+0x392>
		}

		// process main conversion character
		negative = 0;
		numeric = 0;
		switch (*format) {
  20036b:	3c 75                	cmp    $0x75,%al
  20036d:	74 58                	je     2003c7 <console_vprintf+0x19a>
  20036f:	3c 78                	cmp    $0x78,%al
  200371:	74 69                	je     2003dc <console_vprintf+0x1af>
  200373:	3c 73                	cmp    $0x73,%al
  200375:	0f 85 ac 00 00 00    	jne    200427 <console_vprintf+0x1fa>
			data = fill_numbuf(numbuf + NUMBUFSIZ, x, 16, upper_digits, precision);
			numeric = 1;
			break;
		}
		case 's':
			data = va_arg(val, char *);
  20037b:	8b 03                	mov    (%ebx),%eax
  20037d:	83 c3 04             	add    $0x4,%ebx
  200380:	89 44 24 08          	mov    %eax,0x8(%esp)
  200384:	e9 bc 00 00 00       	jmp    200445 <console_vprintf+0x218>
		// process main conversion character
		negative = 0;
		numeric = 0;
		switch (*format) {
		case 'd': {
			int x = va_arg(val, int);
  200389:	8d 7b 04             	lea    0x4(%ebx),%edi
  20038c:	8b 1b                	mov    (%ebx),%ebx
			data = fill_numbuf(numbuf + NUMBUFSIZ, x > 0 ? x : -x, 10, upper_digits, precision);
  20038e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  200393:	89 74 24 04          	mov    %esi,0x4(%esp)
  200397:	c7 04 24 c0 06 20 00 	movl   $0x2006c0,(%esp)
  20039e:	89 d8                	mov    %ebx,%eax
  2003a0:	c1 f8 1f             	sar    $0x1f,%eax
  2003a3:	89 c2                	mov    %eax,%edx
  2003a5:	31 da                	xor    %ebx,%edx
  2003a7:	29 c2                	sub    %eax,%edx
  2003a9:	8d 44 24 3c          	lea    0x3c(%esp),%eax
  2003ad:	e8 a7 fd ff ff       	call   200159 <fill_numbuf>
			if (x < 0)
				negative = 1;
  2003b2:	c1 eb 1f             	shr    $0x1f,%ebx
  2003b5:	89 d9                	mov    %ebx,%ecx
		// process main conversion character
		negative = 0;
		numeric = 0;
		switch (*format) {
		case 'd': {
			int x = va_arg(val, int);
  2003b7:	89 fb                	mov    %edi,%ebx
			data = fill_numbuf(numbuf + NUMBUFSIZ, x > 0 ? x : -x, 10, upper_digits, precision);
			if (x < 0)
				negative = 1;
			numeric = 1;
  2003b9:	bf 01 00 00 00       	mov    $0x1,%edi
		negative = 0;
		numeric = 0;
		switch (*format) {
		case 'd': {
			int x = va_arg(val, int);
			data = fill_numbuf(numbuf + NUMBUFSIZ, x > 0 ? x : -x, 10, upper_digits, precision);
  2003be:	89 44 24 08          	mov    %eax,0x8(%esp)
  2003c2:	e9 82 00 00 00       	jmp    200449 <console_vprintf+0x21c>
				negative = 1;
			numeric = 1;
			break;
		}
		case 'u': {
			unsigned x = va_arg(val, unsigned);
  2003c7:	8d 7b 04             	lea    0x4(%ebx),%edi
			data = fill_numbuf(numbuf + NUMBUFSIZ, x, 10, upper_digits, precision);
  2003ca:	b9 0a 00 00 00       	mov    $0xa,%ecx
  2003cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  2003d3:	c7 04 24 c0 06 20 00 	movl   $0x2006c0,(%esp)
  2003da:	eb 23                	jmp    2003ff <console_vprintf+0x1d2>
			numeric = 1;
			break;
		}
		case 'x': {
			unsigned x = va_arg(val, unsigned);
  2003dc:	8d 7b 04             	lea    0x4(%ebx),%edi
			data = fill_numbuf(numbuf + NUMBUFSIZ, x, 16, lower_digits, precision);
  2003df:	89 74 24 04          	mov    %esi,0x4(%esp)
  2003e3:	c7 04 24 ac 06 20 00 	movl   $0x2006ac,(%esp)
  2003ea:	eb 0e                	jmp    2003fa <console_vprintf+0x1cd>
			numeric = 1;
			break;
		}
		case 'X': {
			unsigned x = va_arg(val, unsigned);
  2003ec:	8d 7b 04             	lea    0x4(%ebx),%edi
			data = fill_numbuf(numbuf + NUMBUFSIZ, x, 16, upper_digits, precision);
  2003ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  2003f3:	c7 04 24 c0 06 20 00 	movl   $0x2006c0,(%esp)
  2003fa:	b9 10 00 00 00       	mov    $0x10,%ecx
  2003ff:	8b 13                	mov    (%ebx),%edx
  200401:	8d 44 24 3c          	lea    0x3c(%esp),%eax
			data = fill_numbuf(numbuf + NUMBUFSIZ, x, 16, lower_digits, precision);
			numeric = 1;
			break;
		}
		case 'X': {
			unsigned x = va_arg(val, unsigned);
  200405:	89 fb                	mov    %edi,%ebx
			data = fill_numbuf(numbuf + NUMBUFSIZ, x, 16, upper_digits, precision);
			numeric = 1;
  200407:	bf 01 00 00 00       	mov    $0x1,%edi
			numeric = 1;
			break;
		}
		case 'X': {
			unsigned x = va_arg(val, unsigned);
			data = fill_numbuf(numbuf + NUMBUFSIZ, x, 16, upper_digits, precision);
  20040c:	e8 48 fd ff ff       	call   200159 <fill_numbuf>
  200411:	89 44 24 08          	mov    %eax,0x8(%esp)
  200415:	eb 30                	jmp    200447 <console_vprintf+0x21a>
		case 'C':
			color = va_arg(val, int);
			goto done;
		case 'c':
			data = numbuf;
			numbuf[0] = va_arg(val, int);
  200417:	8b 03                	mov    (%ebx),%eax
  200419:	83 c3 04             	add    $0x4,%ebx
			numbuf[1] = '\0';
  20041c:	c6 44 24 29 00       	movb   $0x0,0x29(%esp)
		case 'C':
			color = va_arg(val, int);
			goto done;
		case 'c':
			data = numbuf;
			numbuf[0] = va_arg(val, int);
  200421:	88 44 24 28          	mov    %al,0x28(%esp)
  200425:	eb 16                	jmp    20043d <console_vprintf+0x210>
			numbuf[1] = '\0';
			break;
		normal:
		default:
			data = numbuf;
			numbuf[0] = (*format ? *format : '%');
  200427:	b2 25                	mov    $0x25,%dl
  200429:	84 c0                	test   %al,%al
  20042b:	0f 45 d0             	cmovne %eax,%edx
  20042e:	88 54 24 28          	mov    %dl,0x28(%esp)
			numbuf[1] = '\0';
  200432:	c6 44 24 29 00       	movb   $0x0,0x29(%esp)
			if (!*format)
  200437:	75 04                	jne    20043d <console_vprintf+0x210>
				format--;
  200439:	ff 4c 24 58          	decl   0x58(%esp)
			numbuf[0] = va_arg(val, int);
			numbuf[1] = '\0';
			break;
		normal:
		default:
			data = numbuf;
  20043d:	8d 44 24 28          	lea    0x28(%esp),%eax
  200441:	89 44 24 08          	mov    %eax,0x8(%esp)
				precision = 0;
		}

		// process main conversion character
		negative = 0;
		numeric = 0;
  200445:	31 ff                	xor    %edi,%edi
			if (precision < 0)
				precision = 0;
		}

		// process main conversion character
		negative = 0;
  200447:	31 c9                	xor    %ecx,%ecx
			if (!*format)
				format--;
			break;
		}

		if (precision >= 0)
  200449:	83 fe ff             	cmp    $0xffffffff,%esi
  20044c:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  200450:	74 12                	je     200464 <console_vprintf+0x237>
			len = strnlen(data, precision);
  200452:	8b 44 24 08          	mov    0x8(%esp),%eax
  200456:	89 74 24 04          	mov    %esi,0x4(%esp)
  20045a:	89 04 24             	mov    %eax,(%esp)
  20045d:	e8 b5 fd ff ff       	call   200217 <strnlen>
  200462:	eb 0c                	jmp    200470 <console_vprintf+0x243>
		else
			len = strlen(data);
  200464:	8b 44 24 08          	mov    0x8(%esp),%eax
  200468:	89 04 24             	mov    %eax,(%esp)
  20046b:	e8 97 fd ff ff       	call   200207 <strlen>
  200470:	8b 4c 24 18          	mov    0x18(%esp),%ecx
		if (numeric && negative)
			negative = '-';
  200474:	ba 2d 00 00 00       	mov    $0x2d,%edx
		}

		if (precision >= 0)
			len = strnlen(data, precision);
		else
			len = strlen(data);
  200479:	89 44 24 10          	mov    %eax,0x10(%esp)
		if (numeric && negative)
  20047d:	89 f8                	mov    %edi,%eax
  20047f:	83 e0 01             	and    $0x1,%eax
  200482:	88 44 24 18          	mov    %al,0x18(%esp)
  200486:	89 f8                	mov    %edi,%eax
  200488:	84 c8                	test   %cl,%al
  20048a:	75 17                	jne    2004a3 <console_vprintf+0x276>
			negative = '-';
		else if (flags & FLAG_PLUSPOSITIVE)
  20048c:	f6 44 24 14 10       	testb  $0x10,0x14(%esp)
			negative = '+';
  200491:	b2 2b                	mov    $0x2b,%dl
			len = strnlen(data, precision);
		else
			len = strlen(data);
		if (numeric && negative)
			negative = '-';
		else if (flags & FLAG_PLUSPOSITIVE)
  200493:	75 0e                	jne    2004a3 <console_vprintf+0x276>
			negative = '+';
		else if (flags & FLAG_SPACEPOSITIVE)
			negative = ' ';
  200495:	8b 44 24 14          	mov    0x14(%esp),%eax
  200499:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  2004a0:	83 e2 20             	and    $0x20,%edx
		else
			negative = 0;
		if (numeric && precision > len)
  2004a3:	3b 74 24 10          	cmp    0x10(%esp),%esi
  2004a7:	7e 0f                	jle    2004b8 <console_vprintf+0x28b>
  2004a9:	80 7c 24 18 00       	cmpb   $0x0,0x18(%esp)
  2004ae:	74 08                	je     2004b8 <console_vprintf+0x28b>
			zeros = precision - len;
  2004b0:	2b 74 24 10          	sub    0x10(%esp),%esi
  2004b4:	89 f7                	mov    %esi,%edi
  2004b6:	eb 3a                	jmp    2004f2 <console_vprintf+0x2c5>
		else if ((flags & (FLAG_ZERO | FLAG_LEFTJUSTIFY)) == FLAG_ZERO
  2004b8:	8b 4c 24 14          	mov    0x14(%esp),%ecx
			 && numeric && precision < 0
			 && len + !!negative < width)
			zeros = width - len - !!negative;
		else
			zeros = 0;
  2004bc:	31 ff                	xor    %edi,%edi
			negative = ' ';
		else
			negative = 0;
		if (numeric && precision > len)
			zeros = precision - len;
		else if ((flags & (FLAG_ZERO | FLAG_LEFTJUSTIFY)) == FLAG_ZERO
  2004be:	83 e1 06             	and    $0x6,%ecx
  2004c1:	83 f9 02             	cmp    $0x2,%ecx
  2004c4:	75 2c                	jne    2004f2 <console_vprintf+0x2c5>
			 && numeric && precision < 0
  2004c6:	80 7c 24 18 00       	cmpb   $0x0,0x18(%esp)
  2004cb:	74 23                	je     2004f0 <console_vprintf+0x2c3>
  2004cd:	c1 ee 1f             	shr    $0x1f,%esi
  2004d0:	74 1e                	je     2004f0 <console_vprintf+0x2c3>
			 && len + !!negative < width)
  2004d2:	8b 74 24 10          	mov    0x10(%esp),%esi
  2004d6:	31 c0                	xor    %eax,%eax
  2004d8:	85 d2                	test   %edx,%edx
  2004da:	0f 95 c0             	setne  %al
  2004dd:	8d 0c 06             	lea    (%esi,%eax,1),%ecx
  2004e0:	3b 4c 24 0c          	cmp    0xc(%esp),%ecx
  2004e4:	7d 0c                	jge    2004f2 <console_vprintf+0x2c5>
			zeros = width - len - !!negative;
  2004e6:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  2004ea:	29 f7                	sub    %esi,%edi
  2004ec:	29 c7                	sub    %eax,%edi
  2004ee:	eb 02                	jmp    2004f2 <console_vprintf+0x2c5>
		else
			zeros = 0;
  2004f0:	31 ff                	xor    %edi,%edi
		width -= len + zeros + !!negative;
  2004f2:	8b 74 24 10          	mov    0x10(%esp),%esi
  2004f6:	85 d2                	test   %edx,%edx
  2004f8:	0f 95 c0             	setne  %al
  2004fb:	0f b6 c8             	movzbl %al,%ecx
  2004fe:	01 fe                	add    %edi,%esi
  200500:	01 f1                	add    %esi,%ecx
  200502:	8b 74 24 0c          	mov    0xc(%esp),%esi
  200506:	29 ce                	sub    %ecx,%esi
	if (c == '\n') {
		int pos = (cursor - CONSOLE_BEGIN) % 80;
		for (; pos != 80; pos++)
			*cursor++ = ' ' | color;
	} else
		*cursor++ = c | color;
  200508:	8b 4c 24 54          	mov    0x54(%esp),%ecx
  20050c:	83 c9 20             	or     $0x20,%ecx
			 && len + !!negative < width)
			zeros = width - len - !!negative;
		else
			zeros = 0;
		width -= len + zeros + !!negative;
		for (; !(flags & FLAG_LEFTJUSTIFY) && width > 0; --width)
  20050f:	f6 44 24 14 04       	testb  $0x4,0x14(%esp)
	if (c == '\n') {
		int pos = (cursor - CONSOLE_BEGIN) % 80;
		for (; pos != 80; pos++)
			*cursor++ = ' ' | color;
	} else
		*cursor++ = c | color;
  200514:	66 89 4c 24 0c       	mov    %cx,0xc(%esp)
			 && len + !!negative < width)
			zeros = width - len - !!negative;
		else
			zeros = 0;
		width -= len + zeros + !!negative;
		for (; !(flags & FLAG_LEFTJUSTIFY) && width > 0; --width)
  200519:	74 13                	je     20052e <console_vprintf+0x301>
			cursor = console_putc(cursor, ' ', color);
		if (negative)
  20051b:	84 c0                	test   %al,%al
  20051d:	74 2f                	je     20054e <console_vprintf+0x321>
			cursor = console_putc(cursor, negative, color);
  20051f:	8b 4c 24 54          	mov    0x54(%esp),%ecx
  200523:	89 e8                	mov    %ebp,%eax
  200525:	e8 e2 fb ff ff       	call   20010c <console_putc>
  20052a:	89 c5                	mov    %eax,%ebp
  20052c:	eb 20                	jmp    20054e <console_vprintf+0x321>
			 && len + !!negative < width)
			zeros = width - len - !!negative;
		else
			zeros = 0;
		width -= len + zeros + !!negative;
		for (; !(flags & FLAG_LEFTJUSTIFY) && width > 0; --width)
  20052e:	85 f6                	test   %esi,%esi
  200530:	7e e9                	jle    20051b <console_vprintf+0x2ee>

static uint16_t *
console_putc(uint16_t *cursor, unsigned char c, int color)
{
	if (cursor >= CONSOLE_END)
		cursor = CONSOLE_BEGIN;
  200532:	81 fd a0 8f 0b 00    	cmp    $0xb8fa0,%ebp
  200538:	b9 00 80 0b 00       	mov    $0xb8000,%ecx
  20053d:	0f 43 e9             	cmovae %ecx,%ebp
	if (c == '\n') {
		int pos = (cursor - CONSOLE_BEGIN) % 80;
		for (; pos != 80; pos++)
			*cursor++ = ' ' | color;
	} else
		*cursor++ = c | color;
  200540:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
			 && len + !!negative < width)
			zeros = width - len - !!negative;
		else
			zeros = 0;
		width -= len + zeros + !!negative;
		for (; !(flags & FLAG_LEFTJUSTIFY) && width > 0; --width)
  200544:	4e                   	dec    %esi
			cursor = console_putc(cursor, ' ', color);
  200545:	83 c5 02             	add    $0x2,%ebp
	if (c == '\n') {
		int pos = (cursor - CONSOLE_BEGIN) % 80;
		for (; pos != 80; pos++)
			*cursor++ = ' ' | color;
	} else
		*cursor++ = c | color;
  200548:	66 89 4d fe          	mov    %cx,-0x2(%ebp)
  20054c:	eb e0                	jmp    20052e <console_vprintf+0x301>
  20054e:	8b 54 24 54          	mov    0x54(%esp),%edx

static uint16_t *
console_putc(uint16_t *cursor, unsigned char c, int color)
{
	if (cursor >= CONSOLE_END)
		cursor = CONSOLE_BEGIN;
  200552:	b8 00 80 0b 00       	mov    $0xb8000,%eax
	if (c == '\n') {
		int pos = (cursor - CONSOLE_BEGIN) % 80;
		for (; pos != 80; pos++)
			*cursor++ = ' ' | color;
	} else
		*cursor++ = c | color;
  200557:	83 ca 30             	or     $0x30,%edx
		width -= len + zeros + !!negative;
		for (; !(flags & FLAG_LEFTJUSTIFY) && width > 0; --width)
			cursor = console_putc(cursor, ' ', color);
		if (negative)
			cursor = console_putc(cursor, negative, color);
		for (; zeros > 0; --zeros)
  20055a:	85 ff                	test   %edi,%edi
  20055c:	7e 13                	jle    200571 <console_vprintf+0x344>

static uint16_t *
console_putc(uint16_t *cursor, unsigned char c, int color)
{
	if (cursor >= CONSOLE_END)
		cursor = CONSOLE_BEGIN;
  20055e:	81 fd a0 8f 0b 00    	cmp    $0xb8fa0,%ebp
  200564:	0f 43 e8             	cmovae %eax,%ebp
		width -= len + zeros + !!negative;
		for (; !(flags & FLAG_LEFTJUSTIFY) && width > 0; --width)
			cursor = console_putc(cursor, ' ', color);
		if (negative)
			cursor = console_putc(cursor, negative, color);
		for (; zeros > 0; --zeros)
  200567:	4f                   	dec    %edi
	if (c == '\n') {
		int pos = (cursor - CONSOLE_BEGIN) % 80;
		for (; pos != 80; pos++)
			*cursor++ = ' ' | color;
	} else
		*cursor++ = c | color;
  200568:	66 89 55 00          	mov    %dx,0x0(%ebp)
		for (; !(flags & FLAG_LEFTJUSTIFY) && width > 0; --width)
			cursor = console_putc(cursor, ' ', color);
		if (negative)
			cursor = console_putc(cursor, negative, color);
		for (; zeros > 0; --zeros)
			cursor = console_putc(cursor, '0', color);
  20056c:	83 c5 02             	add    $0x2,%ebp
  20056f:	eb e9                	jmp    20055a <console_vprintf+0x32d>
		width -= len + zeros + !!negative;
		for (; !(flags & FLAG_LEFTJUSTIFY) && width > 0; --width)
			cursor = console_putc(cursor, ' ', color);
		if (negative)
			cursor = console_putc(cursor, negative, color);
		for (; zeros > 0; --zeros)
  200571:	8b 7c 24 08          	mov    0x8(%esp),%edi
  200575:	8b 44 24 10          	mov    0x10(%esp),%eax
  200579:	01 f8                	add    %edi,%eax
  20057b:	89 44 24 08          	mov    %eax,0x8(%esp)
  20057f:	8b 44 24 08          	mov    0x8(%esp),%eax
  200583:	29 f8                	sub    %edi,%eax
			cursor = console_putc(cursor, '0', color);
		for (; len > 0; ++data, --len)
  200585:	85 c0                	test   %eax,%eax
  200587:	7e 13                	jle    20059c <console_vprintf+0x36f>
			cursor = console_putc(cursor, *data, color);
  200589:	0f b6 17             	movzbl (%edi),%edx
  20058c:	89 e8                	mov    %ebp,%eax
			cursor = console_putc(cursor, ' ', color);
		if (negative)
			cursor = console_putc(cursor, negative, color);
		for (; zeros > 0; --zeros)
			cursor = console_putc(cursor, '0', color);
		for (; len > 0; ++data, --len)
  20058e:	47                   	inc    %edi
			cursor = console_putc(cursor, *data, color);
  20058f:	8b 4c 24 54          	mov    0x54(%esp),%ecx
  200593:	e8 74 fb ff ff       	call   20010c <console_putc>
  200598:	89 c5                	mov    %eax,%ebp
  20059a:	eb e3                	jmp    20057f <console_vprintf+0x352>
	if (c == '\n') {
		int pos = (cursor - CONSOLE_BEGIN) % 80;
		for (; pos != 80; pos++)
			*cursor++ = ' ' | color;
	} else
		*cursor++ = c | color;
  20059c:	8b 54 24 54          	mov    0x54(%esp),%edx

static uint16_t *
console_putc(uint16_t *cursor, unsigned char c, int color)
{
	if (cursor >= CONSOLE_END)
		cursor = CONSOLE_BEGIN;
  2005a0:	b8 00 80 0b 00       	mov    $0xb8000,%eax
	if (c == '\n') {
		int pos = (cursor - CONSOLE_BEGIN) % 80;
		for (; pos != 80; pos++)
			*cursor++ = ' ' | color;
	} else
		*cursor++ = c | color;
  2005a5:	83 ca 20             	or     $0x20,%edx
			cursor = console_putc(cursor, negative, color);
		for (; zeros > 0; --zeros)
			cursor = console_putc(cursor, '0', color);
		for (; len > 0; ++data, --len)
			cursor = console_putc(cursor, *data, color);
		for (; width > 0; --width)
  2005a8:	85 f6                	test   %esi,%esi
  2005aa:	7e 13                	jle    2005bf <console_vprintf+0x392>

static uint16_t *
console_putc(uint16_t *cursor, unsigned char c, int color)
{
	if (cursor >= CONSOLE_END)
		cursor = CONSOLE_BEGIN;
  2005ac:	81 fd a0 8f 0b 00    	cmp    $0xb8fa0,%ebp
  2005b2:	0f 43 e8             	cmovae %eax,%ebp
			cursor = console_putc(cursor, negative, color);
		for (; zeros > 0; --zeros)
			cursor = console_putc(cursor, '0', color);
		for (; len > 0; ++data, --len)
			cursor = console_putc(cursor, *data, color);
		for (; width > 0; --width)
  2005b5:	4e                   	dec    %esi
	if (c == '\n') {
		int pos = (cursor - CONSOLE_BEGIN) % 80;
		for (; pos != 80; pos++)
			*cursor++ = ' ' | color;
	} else
		*cursor++ = c | color;
  2005b6:	66 89 55 00          	mov    %dx,0x0(%ebp)
		for (; zeros > 0; --zeros)
			cursor = console_putc(cursor, '0', color);
		for (; len > 0; ++data, --len)
			cursor = console_putc(cursor, *data, color);
		for (; width > 0; --width)
			cursor = console_putc(cursor, ' ', color);
  2005ba:	83 c5 02             	add    $0x2,%ebp
  2005bd:	eb e9                	jmp    2005a8 <console_vprintf+0x37b>
	int flags, width, zeros, precision, negative, numeric, len;
#define NUMBUFSIZ 20
	char numbuf[NUMBUFSIZ];
	char *data;

	for (; *format; ++format) {
  2005bf:	ff 44 24 58          	incl   0x58(%esp)
  2005c3:	e9 74 fc ff ff       	jmp    20023c <console_vprintf+0xf>
			const char *flagc = flag_chars;
			while (*flagc != '\0' && *flagc != *format)
				++flagc;
			if (*flagc == '\0')
				break;
			flags |= (1 << (flagc - flag_chars));
  2005c8:	81 e9 a4 06 20 00    	sub    $0x2006a4,%ecx
  2005ce:	89 f0                	mov    %esi,%eax
  2005d0:	d3 e0                	shl    %cl,%eax
			continue;
		}

		// process flags
		flags = 0;
		for (++format; *format; ++format) {
  2005d2:	ff 44 24 58          	incl   0x58(%esp)
			const char *flagc = flag_chars;
			while (*flagc != '\0' && *flagc != *format)
				++flagc;
			if (*flagc == '\0')
				break;
			flags |= (1 << (flagc - flag_chars));
  2005d6:	09 44 24 14          	or     %eax,0x14(%esp)
  2005da:	e9 94 fc ff ff       	jmp    200273 <console_vprintf+0x46>
			cursor = console_putc(cursor, ' ', color);
	done: ;
	}

	return cursor;
}
  2005df:	83 c4 3c             	add    $0x3c,%esp
  2005e2:	89 e8                	mov    %ebp,%eax
  2005e4:	5b                   	pop    %ebx
  2005e5:	5e                   	pop    %esi
  2005e6:	5f                   	pop    %edi
  2005e7:	5d                   	pop    %ebp
  2005e8:	c3                   	ret    

002005e9 <console_printf>:

uint16_t *
console_printf(uint16_t *cursor, int color, const char *format, ...)
{
  2005e9:	83 ec 10             	sub    $0x10,%esp
	va_list val;
	va_start(val, format);
	cursor = console_vprintf(cursor, color, format, val);
  2005ec:	8d 44 24 20          	lea    0x20(%esp),%eax
  2005f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  2005f4:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  2005f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  2005fc:	8b 44 24 18          	mov    0x18(%esp),%eax
  200600:	89 44 24 04          	mov    %eax,0x4(%esp)
  200604:	8b 44 24 14          	mov    0x14(%esp),%eax
  200608:	89 04 24             	mov    %eax,(%esp)
  20060b:	e8 1d fc ff ff       	call   20022d <console_vprintf>
	va_end(val);
	return cursor;
}
  200610:	83 c4 10             	add    $0x10,%esp
  200613:	c3                   	ret    
