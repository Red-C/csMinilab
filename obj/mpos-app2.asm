
obj/mpos-app2:     file format elf32-i386


Disassembly of section .text:

00200000 <app_printf.constprop.0>:
 *****************************************************************************/

static void app_printf(const char *format, ...) __attribute__((noinline));

static void
app_printf(const char *format, ...)
  200000:	83 ec 2c             	sub    $0x2c,%esp
  200003:	c7 44 24 1c dc 05 20 	movl   $0x2005dc,0x1c(%esp)
  20000a:	00 
	// That means that after the "asm" instruction (which causes the
	// interrupt), the system call's return value is in the 'pid'
	// variable, and we can just return that value!

	pid_t pid;
	asm volatile("int %1\n"
  20000b:	cd 30                	int    $0x30
static void
app_printf(const char *format, ...)
{
	// set default color based on currently running process
	int color = sys_getpid();
	if (color < 0)
  20000d:	85 c0                	test   %eax,%eax
  20000f:	78 15                	js     200026 <app_printf.constprop.0+0x26>
		color = 0x0700;
	else {
		static const uint8_t col[] = { 0x0E, 0x0F, 0x0C, 0x0A, 0x09 };
		color = col[color % sizeof(col)] << 8;
  200011:	b9 05 00 00 00       	mov    $0x5,%ecx
  200016:	31 d2                	xor    %edx,%edx
  200018:	f7 f1                	div    %ecx
  20001a:	0f b6 82 fc 05 20 00 	movzbl 0x2005fc(%edx),%eax
  200021:	c1 e0 08             	shl    $0x8,%eax
  200024:	eb 05                	jmp    20002b <app_printf.constprop.0+0x2b>
app_printf(const char *format, ...)
{
	// set default color based on currently running process
	int color = sys_getpid();
	if (color < 0)
		color = 0x0700;
  200026:	b8 00 07 00 00       	mov    $0x700,%eax
		color = col[color % sizeof(col)] << 8;
	}

	va_list val;
	va_start(val, format);
	cursorpos = console_vprintf(cursorpos, color, format, val);
  20002b:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  20002f:	8d 4c 24 20          	lea    0x20(%esp),%ecx
  200033:	89 44 24 04          	mov    %eax,0x4(%esp)
  200037:	a1 00 00 06 00       	mov    0x60000,%eax
  20003c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  200040:	89 54 24 08          	mov    %edx,0x8(%esp)
  200044:	89 04 24             	mov    %eax,(%esp)
  200047:	e8 a7 01 00 00       	call   2001f3 <console_vprintf>
  20004c:	a3 00 00 06 00       	mov    %eax,0x60000
	va_end(val);
}
  200051:	83 c4 2c             	add    $0x2c,%esp
  200054:	c3                   	ret    

00200055 <run_child>:
	sys_exit(0);
}

void
run_child(void)
{
  200055:	53                   	push   %ebx
  200056:	83 ec 08             	sub    $0x8,%esp
	int input_counter = counter;
  200059:	8b 1d c8 17 20 00    	mov    0x2017c8,%ebx

	counter++;		/* Note that all "processes" share an address
  20005f:	a1 c8 17 20 00       	mov    0x2017c8,%eax
  200064:	40                   	inc    %eax
  200065:	a3 c8 17 20 00       	mov    %eax,0x2017c8
	// That means that after the "asm" instruction (which causes the
	// interrupt), the system call's return value is in the 'pid'
	// variable, and we can just return that value!

	pid_t pid;
	asm volatile("int %1\n"
  20006a:	cd 30                	int    $0x30
				   space, so this change to 'counter' will be
				   visible to all processes. */

	app_printf("Process %d lives, counter %d!\n",
  20006c:	89 da                	mov    %ebx,%edx
  20006e:	e8 8d ff ff ff       	call   200000 <app_printf.constprop.0>
	// the 'int' instruction.
	// You can load other registers with similar syntax; specifically:
	//	"a" = %eax, "b" = %ebx, "c" = %ecx, "d" = %edx,
	//	"S" = %esi, "D" = %edi.

	asm volatile("int %0\n"
  200073:	89 d8                	mov    %ebx,%eax
  200075:	cd 33                	int    $0x33
  200077:	eb fe                	jmp    200077 <run_child+0x22>

00200079 <start>:
start(void)
{
	pid_t p;
	int status;

	counter = 0;
  200079:	c7 05 c8 17 20 00 00 	movl   $0x0,0x2017c8
  200080:	00 00 00 

	while (counter < 1025) {
  200083:	a1 c8 17 20 00       	mov    0x2017c8,%eax
  200088:	3d 00 04 00 00       	cmp    $0x400,%eax
  20008d:	7e 06                	jle    200095 <start+0x1c>
  20008f:	31 c0                	xor    %eax,%eax
  200091:	cd 33                	int    $0x33
  200093:	eb 3b                	jmp    2000d0 <start+0x57>
  200095:	31 d2                	xor    %edx,%edx
		int n_started = 0;

		// Start as many processes as possible, until we fail to start
		// a process or we have started 1025 processes total.
		while (counter + n_started < 1025) {
  200097:	a1 c8 17 20 00       	mov    0x2017c8,%eax
  20009c:	01 d0                	add    %edx,%eax
  20009e:	3d 00 04 00 00       	cmp    $0x400,%eax
  2000a3:	7f 11                	jg     2000b6 <start+0x3d>
sys_fork(void)
{
	// This system call follows the same pattern as sys_getpid().

	pid_t result;
	asm volatile("int %1\n"
  2000a5:	cd 31                	int    $0x31
			p = sys_fork();
			if (p == 0)
  2000a7:	83 f8 00             	cmp    $0x0,%eax
  2000aa:	75 08                	jne    2000b4 <start+0x3b>

void run_child(void);

void
start(void)
{
  2000ac:	83 ec 0c             	sub    $0xc,%esp
		// Start as many processes as possible, until we fail to start
		// a process or we have started 1025 processes total.
		while (counter + n_started < 1025) {
			p = sys_fork();
			if (p == 0)
				run_child();
  2000af:	e8 a1 ff ff ff       	call   200055 <run_child>
			else if (p > 0)
  2000b4:	7f 0b                	jg     2000c1 <start+0x48>
			else
				break;
		}

		// If we could not start any new processes, give up!
		if (n_started == 0)
  2000b6:	85 d2                	test   %edx,%edx
  2000b8:	74 d5                	je     20008f <start+0x16>
  2000ba:	ba 02 00 00 00       	mov    $0x2,%edx
  2000bf:	eb 03                	jmp    2000c4 <start+0x4b>
		while (counter + n_started < 1025) {
			p = sys_fork();
			if (p == 0)
				run_child();
			else if (p > 0)
				n_started++;
  2000c1:	42                   	inc    %edx
  2000c2:	eb d3                	jmp    200097 <start+0x1e>

static inline int
sys_wait(pid_t pid)
{
	int retval;
	asm volatile("int %1\n"
  2000c4:	89 d0                	mov    %edx,%eax
  2000c6:	cd 34                	int    $0x34
		// We started at least one process, but then could not start
		// any more.
		// That means we ran out of room to start processes.
		// Retrieve old processes' exit status with sys_wait(),
		// to make room for new processes.
		for (p = 2; p < NPROCS; p++)
  2000c8:	42                   	inc    %edx
  2000c9:	83 fa 10             	cmp    $0x10,%edx
  2000cc:	75 f6                	jne    2000c4 <start+0x4b>
  2000ce:	eb b3                	jmp    200083 <start+0xa>
  2000d0:	eb fe                	jmp    2000d0 <start+0x57>

002000d2 <console_putc>:
 *
 *   Print a message onto the console, starting at the given cursor position. */

static uint16_t *
console_putc(uint16_t *cursor, unsigned char c, int color)
{
  2000d2:	56                   	push   %esi
	if (cursor >= CONSOLE_END)
		cursor = CONSOLE_BEGIN;
  2000d3:	3d a0 8f 0b 00       	cmp    $0xb8fa0,%eax
 *
 *   Print a message onto the console, starting at the given cursor position. */

static uint16_t *
console_putc(uint16_t *cursor, unsigned char c, int color)
{
  2000d8:	53                   	push   %ebx
  2000d9:	89 c3                	mov    %eax,%ebx
	if (cursor >= CONSOLE_END)
		cursor = CONSOLE_BEGIN;
  2000db:	b8 00 80 0b 00       	mov    $0xb8000,%eax
  2000e0:	0f 43 d8             	cmovae %eax,%ebx
	if (c == '\n') {
  2000e3:	80 fa 0a             	cmp    $0xa,%dl
  2000e6:	75 2c                	jne    200114 <console_putc+0x42>
		int pos = (cursor - CONSOLE_BEGIN) % 80;
  2000e8:	8d 83 00 80 f4 ff    	lea    -0xb8000(%ebx),%eax
  2000ee:	be 50 00 00 00       	mov    $0x50,%esi
  2000f3:	d1 f8                	sar    %eax
		for (; pos != 80; pos++)
			*cursor++ = ' ' | color;
  2000f5:	83 c9 20             	or     $0x20,%ecx
console_putc(uint16_t *cursor, unsigned char c, int color)
{
	if (cursor >= CONSOLE_END)
		cursor = CONSOLE_BEGIN;
	if (c == '\n') {
		int pos = (cursor - CONSOLE_BEGIN) % 80;
  2000f8:	99                   	cltd   
  2000f9:	f7 fe                	idiv   %esi
  2000fb:	6b c2 fe             	imul   $0xfffffffe,%edx,%eax
  2000fe:	8d 34 03             	lea    (%ebx,%eax,1),%esi
		for (; pos != 80; pos++)
			*cursor++ = ' ' | color;
  200101:	66 89 0c 56          	mov    %cx,(%esi,%edx,2)
{
	if (cursor >= CONSOLE_END)
		cursor = CONSOLE_BEGIN;
	if (c == '\n') {
		int pos = (cursor - CONSOLE_BEGIN) % 80;
		for (; pos != 80; pos++)
  200105:	42                   	inc    %edx
  200106:	83 fa 50             	cmp    $0x50,%edx
  200109:	75 f6                	jne    200101 <console_putc+0x2f>
  20010b:	8d 84 03 a0 00 00 00 	lea    0xa0(%ebx,%eax,1),%eax
  200112:	eb 08                	jmp    20011c <console_putc+0x4a>
			*cursor++ = ' ' | color;
	} else
		*cursor++ = c | color;
  200114:	09 d1                	or     %edx,%ecx
  200116:	8d 43 02             	lea    0x2(%ebx),%eax
  200119:	66 89 0b             	mov    %cx,(%ebx)
	return cursor;
}
  20011c:	5b                   	pop    %ebx
  20011d:	5e                   	pop    %esi
  20011e:	c3                   	ret    

0020011f <fill_numbuf>:
static const char lower_digits[] = "0123456789abcdef";

static char *
fill_numbuf(char *numbuf_end, uint32_t val, int base, const char *digits,
	    int precision)
{
  20011f:	56                   	push   %esi
  200120:	53                   	push   %ebx
  200121:	8b 74 24 0c          	mov    0xc(%esp),%esi
	*--numbuf_end = '\0';
	if (precision != 0 || val != 0)
  200125:	83 7c 24 10 00       	cmpl   $0x0,0x10(%esp)

static char *
fill_numbuf(char *numbuf_end, uint32_t val, int base, const char *digits,
	    int precision)
{
	*--numbuf_end = '\0';
  20012a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  20012d:	c6 40 ff 00          	movb   $0x0,-0x1(%eax)
	if (precision != 0 || val != 0)
  200131:	75 04                	jne    200137 <fill_numbuf+0x18>
  200133:	85 d2                	test   %edx,%edx
  200135:	74 10                	je     200147 <fill_numbuf+0x28>
		do {
			*--numbuf_end = digits[val % base];
  200137:	89 d0                	mov    %edx,%eax
  200139:	31 d2                	xor    %edx,%edx
  20013b:	f7 f1                	div    %ecx
  20013d:	4b                   	dec    %ebx
  20013e:	8a 14 16             	mov    (%esi,%edx,1),%dl
  200141:	88 13                	mov    %dl,(%ebx)
			val /= base;
  200143:	89 c2                	mov    %eax,%edx
  200145:	eb ec                	jmp    200133 <fill_numbuf+0x14>
		} while (val != 0);
	return numbuf_end;
}
  200147:	89 d8                	mov    %ebx,%eax
  200149:	5b                   	pop    %ebx
  20014a:	5e                   	pop    %esi
  20014b:	c3                   	ret    

0020014c <memcpy>:
 *
 *   We must provide our own implementations of these basic functions. */

void *
memcpy(void *dst, const void *src, size_t n)
{
  20014c:	53                   	push   %ebx
  20014d:	8b 44 24 08          	mov    0x8(%esp),%eax
	const char *s = (const char *) src;
	char *d = (char *) dst;
	while (n-- > 0)
  200151:	31 d2                	xor    %edx,%edx
 *
 *   We must provide our own implementations of these basic functions. */

void *
memcpy(void *dst, const void *src, size_t n)
{
  200153:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
	const char *s = (const char *) src;
	char *d = (char *) dst;
	while (n-- > 0)
  200157:	3b 54 24 10          	cmp    0x10(%esp),%edx
  20015b:	74 09                	je     200166 <memcpy+0x1a>
		*d++ = *s++;
  20015d:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  200160:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  200163:	42                   	inc    %edx
  200164:	eb f1                	jmp    200157 <memcpy+0xb>
	return dst;
}
  200166:	5b                   	pop    %ebx
  200167:	c3                   	ret    

00200168 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  200168:	55                   	push   %ebp
  200169:	57                   	push   %edi
  20016a:	56                   	push   %esi
  20016b:	53                   	push   %ebx
  20016c:	8b 44 24 14          	mov    0x14(%esp),%eax
  200170:	8b 5c 24 18          	mov    0x18(%esp),%ebx
  200174:	8b 6c 24 1c          	mov    0x1c(%esp),%ebp
	const char *s = (const char *) src;
	char *d = (char *) dst;
	if (s < d && s + n > d) {
  200178:	39 c3                	cmp    %eax,%ebx
  20017a:	72 04                	jb     200180 <memmove+0x18>
		s += n, d += n;
		while (n-- > 0)
  20017c:	31 c9                	xor    %ecx,%ecx
  20017e:	eb 24                	jmp    2001a4 <memmove+0x3c>
void *
memmove(void *dst, const void *src, size_t n)
{
	const char *s = (const char *) src;
	char *d = (char *) dst;
	if (s < d && s + n > d) {
  200180:	8d 34 2b             	lea    (%ebx,%ebp,1),%esi
  200183:	39 c6                	cmp    %eax,%esi
  200185:	76 f5                	jbe    20017c <memmove+0x14>
  200187:	89 e9                	mov    %ebp,%ecx
		s += n, d += n;
		while (n-- > 0)
  200189:	89 ea                	mov    %ebp,%edx
  20018b:	f7 d9                	neg    %ecx
memmove(void *dst, const void *src, size_t n)
{
	const char *s = (const char *) src;
	char *d = (char *) dst;
	if (s < d && s + n > d) {
		s += n, d += n;
  20018d:	8d 3c 28             	lea    (%eax,%ebp,1),%edi
  200190:	01 ce                	add    %ecx,%esi
		while (n-- > 0)
  200192:	4a                   	dec    %edx
  200193:	83 fa ff             	cmp    $0xffffffff,%edx
  200196:	74 19                	je     2001b1 <memmove+0x49>
			*--d = *--s;
  200198:	8a 1c 16             	mov    (%esi,%edx,1),%bl
  20019b:	8d 2c 0f             	lea    (%edi,%ecx,1),%ebp
  20019e:	88 5c 15 00          	mov    %bl,0x0(%ebp,%edx,1)
  2001a2:	eb ee                	jmp    200192 <memmove+0x2a>
	} else
		while (n-- > 0)
  2001a4:	39 e9                	cmp    %ebp,%ecx
  2001a6:	74 09                	je     2001b1 <memmove+0x49>
			*d++ = *s++;
  2001a8:	8a 14 0b             	mov    (%ebx,%ecx,1),%dl
  2001ab:	88 14 08             	mov    %dl,(%eax,%ecx,1)
  2001ae:	41                   	inc    %ecx
  2001af:	eb f3                	jmp    2001a4 <memmove+0x3c>
	return dst;
}
  2001b1:	5b                   	pop    %ebx
  2001b2:	5e                   	pop    %esi
  2001b3:	5f                   	pop    %edi
  2001b4:	5d                   	pop    %ebp
  2001b5:	c3                   	ret    

002001b6 <memset>:

void *
memset(void *v, int c, size_t n)
{
  2001b6:	8b 44 24 04          	mov    0x4(%esp),%eax
	char *p = (char *) v;
	while (n-- > 0)
  2001ba:	31 d2                	xor    %edx,%edx
	return dst;
}

void *
memset(void *v, int c, size_t n)
{
  2001bc:	8b 4c 24 08          	mov    0x8(%esp),%ecx
	char *p = (char *) v;
	while (n-- > 0)
  2001c0:	3b 54 24 0c          	cmp    0xc(%esp),%edx
  2001c4:	74 06                	je     2001cc <memset+0x16>
		*p++ = c;
  2001c6:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  2001c9:	42                   	inc    %edx
  2001ca:	eb f4                	jmp    2001c0 <memset+0xa>
	return v;
}
  2001cc:	c3                   	ret    

002001cd <strlen>:

size_t
strlen(const char *s)
{
  2001cd:	8b 54 24 04          	mov    0x4(%esp),%edx
	size_t n;
	for (n = 0; *s != '\0'; ++s)
  2001d1:	31 c0                	xor    %eax,%eax
  2001d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  2001d7:	74 03                	je     2001dc <strlen+0xf>
		++n;
  2001d9:	40                   	inc    %eax
  2001da:	eb f7                	jmp    2001d3 <strlen+0x6>
	return n;
}
  2001dc:	c3                   	ret    

002001dd <strnlen>:

size_t
strnlen(const char *s, size_t maxlen)
{
  2001dd:	8b 54 24 04          	mov    0x4(%esp),%edx
	size_t n;
	for (n = 0; n != maxlen && *s != '\0'; ++s)
  2001e1:	31 c0                	xor    %eax,%eax
  2001e3:	3b 44 24 08          	cmp    0x8(%esp),%eax
  2001e7:	74 09                	je     2001f2 <strnlen+0x15>
  2001e9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  2001ed:	74 03                	je     2001f2 <strnlen+0x15>
		++n;
  2001ef:	40                   	inc    %eax
  2001f0:	eb f1                	jmp    2001e3 <strnlen+0x6>
	return n;
}
  2001f2:	c3                   	ret    

002001f3 <console_vprintf>:
#define FLAG_PLUSPOSITIVE	(1<<4)
static const char flag_chars[] = "#0- +";

uint16_t *
console_vprintf(uint16_t *cursor, int color, const char *format, va_list val)
{
  2001f3:	55                   	push   %ebp
  2001f4:	57                   	push   %edi
  2001f5:	56                   	push   %esi
  2001f6:	53                   	push   %ebx
  2001f7:	83 ec 3c             	sub    $0x3c,%esp
  2001fa:	8b 6c 24 50          	mov    0x50(%esp),%ebp
  2001fe:	8b 5c 24 5c          	mov    0x5c(%esp),%ebx
	int flags, width, zeros, precision, negative, numeric, len;
#define NUMBUFSIZ 20
	char numbuf[NUMBUFSIZ];
	char *data;

	for (; *format; ++format) {
  200202:	8b 44 24 58          	mov    0x58(%esp),%eax
  200206:	0f b6 10             	movzbl (%eax),%edx
  200209:	84 d2                	test   %dl,%dl
  20020b:	0f 84 94 03 00 00    	je     2005a5 <console_vprintf+0x3b2>
		if (*format != '%') {
  200211:	80 fa 25             	cmp    $0x25,%dl
  200214:	74 12                	je     200228 <console_vprintf+0x35>
			cursor = console_putc(cursor, *format, color);
  200216:	8b 4c 24 54          	mov    0x54(%esp),%ecx
  20021a:	89 e8                	mov    %ebp,%eax
  20021c:	e8 b1 fe ff ff       	call   2000d2 <console_putc>
  200221:	89 c5                	mov    %eax,%ebp
			continue;
  200223:	e9 5d 03 00 00       	jmp    200585 <console_vprintf+0x392>
		}

		// process flags
		flags = 0;
		for (++format; *format; ++format) {
  200228:	ff 44 24 58          	incl   0x58(%esp)
			const char *flagc = flag_chars;
			while (*flagc != '\0' && *flagc != *format)
				++flagc;
			if (*flagc == '\0')
				break;
			flags |= (1 << (flagc - flag_chars));
  20022c:	be 01 00 00 00       	mov    $0x1,%esi
			cursor = console_putc(cursor, *format, color);
			continue;
		}

		// process flags
		flags = 0;
  200231:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  200238:	00 
		for (++format; *format; ++format) {
  200239:	8b 44 24 58          	mov    0x58(%esp),%eax
  20023d:	8a 00                	mov    (%eax),%al
  20023f:	84 c0                	test   %al,%al
  200241:	74 16                	je     200259 <console_vprintf+0x66>
  200243:	b9 04 06 20 00       	mov    $0x200604,%ecx
			const char *flagc = flag_chars;
			while (*flagc != '\0' && *flagc != *format)
  200248:	8a 11                	mov    (%ecx),%dl
  20024a:	84 d2                	test   %dl,%dl
  20024c:	74 0b                	je     200259 <console_vprintf+0x66>
  20024e:	38 c2                	cmp    %al,%dl
  200250:	0f 84 38 03 00 00    	je     20058e <console_vprintf+0x39b>
				++flagc;
  200256:	41                   	inc    %ecx
  200257:	eb ef                	jmp    200248 <console_vprintf+0x55>
			flags |= (1 << (flagc - flag_chars));
		}

		// process width
		width = -1;
		if (*format >= '1' && *format <= '9') {
  200259:	8d 50 cf             	lea    -0x31(%eax),%edx
  20025c:	80 fa 08             	cmp    $0x8,%dl
  20025f:	77 2a                	ja     20028b <console_vprintf+0x98>
  200261:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  200268:	00 
			for (width = 0; *format >= '0' && *format <= '9'; )
  200269:	8b 44 24 58          	mov    0x58(%esp),%eax
  20026d:	0f be 00             	movsbl (%eax),%eax
  200270:	8d 50 d0             	lea    -0x30(%eax),%edx
  200273:	80 fa 09             	cmp    $0x9,%dl
  200276:	77 2c                	ja     2002a4 <console_vprintf+0xb1>
				width = 10 * width + *format++ - '0';
  200278:	6b 74 24 0c 0a       	imul   $0xa,0xc(%esp),%esi
  20027d:	ff 44 24 58          	incl   0x58(%esp)
  200281:	8d 44 06 d0          	lea    -0x30(%esi,%eax,1),%eax
  200285:	89 44 24 0c          	mov    %eax,0xc(%esp)
  200289:	eb de                	jmp    200269 <console_vprintf+0x76>
		} else if (*format == '*') {
  20028b:	3c 2a                	cmp    $0x2a,%al
				break;
			flags |= (1 << (flagc - flag_chars));
		}

		// process width
		width = -1;
  20028d:	c7 44 24 0c ff ff ff 	movl   $0xffffffff,0xc(%esp)
  200294:	ff 
		if (*format >= '1' && *format <= '9') {
			for (width = 0; *format >= '0' && *format <= '9'; )
				width = 10 * width + *format++ - '0';
		} else if (*format == '*') {
  200295:	75 0d                	jne    2002a4 <console_vprintf+0xb1>
			width = va_arg(val, int);
  200297:	8b 03                	mov    (%ebx),%eax
  200299:	83 c3 04             	add    $0x4,%ebx
			++format;
  20029c:	ff 44 24 58          	incl   0x58(%esp)
		width = -1;
		if (*format >= '1' && *format <= '9') {
			for (width = 0; *format >= '0' && *format <= '9'; )
				width = 10 * width + *format++ - '0';
		} else if (*format == '*') {
			width = va_arg(val, int);
  2002a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
			++format;
		}

		// process precision
		precision = -1;
		if (*format == '.') {
  2002a4:	8b 44 24 58          	mov    0x58(%esp),%eax
			width = va_arg(val, int);
			++format;
		}

		// process precision
		precision = -1;
  2002a8:	83 ce ff             	or     $0xffffffff,%esi
		if (*format == '.') {
  2002ab:	80 38 2e             	cmpb   $0x2e,(%eax)
  2002ae:	75 4f                	jne    2002ff <console_vprintf+0x10c>
			++format;
			if (*format >= '0' && *format <= '9') {
  2002b0:	8b 7c 24 58          	mov    0x58(%esp),%edi
		}

		// process precision
		precision = -1;
		if (*format == '.') {
			++format;
  2002b4:	40                   	inc    %eax
			if (*format >= '0' && *format <= '9') {
  2002b5:	8a 57 01             	mov    0x1(%edi),%dl
  2002b8:	8d 4a d0             	lea    -0x30(%edx),%ecx
  2002bb:	80 f9 09             	cmp    $0x9,%cl
  2002be:	77 22                	ja     2002e2 <console_vprintf+0xef>
  2002c0:	89 44 24 58          	mov    %eax,0x58(%esp)
  2002c4:	31 f6                	xor    %esi,%esi
				for (precision = 0; *format >= '0' && *format <= '9'; )
  2002c6:	8b 44 24 58          	mov    0x58(%esp),%eax
  2002ca:	0f be 00             	movsbl (%eax),%eax
  2002cd:	8d 50 d0             	lea    -0x30(%eax),%edx
  2002d0:	80 fa 09             	cmp    $0x9,%dl
  2002d3:	77 2a                	ja     2002ff <console_vprintf+0x10c>
					precision = 10 * precision + *format++ - '0';
  2002d5:	6b f6 0a             	imul   $0xa,%esi,%esi
  2002d8:	ff 44 24 58          	incl   0x58(%esp)
  2002dc:	8d 74 06 d0          	lea    -0x30(%esi,%eax,1),%esi
  2002e0:	eb e4                	jmp    2002c6 <console_vprintf+0xd3>
			} else if (*format == '*') {
  2002e2:	80 fa 2a             	cmp    $0x2a,%dl
  2002e5:	75 12                	jne    2002f9 <console_vprintf+0x106>
				precision = va_arg(val, int);
  2002e7:	8b 33                	mov    (%ebx),%esi
  2002e9:	8d 43 04             	lea    0x4(%ebx),%eax
				++format;
  2002ec:	83 44 24 58 02       	addl   $0x2,0x58(%esp)
			++format;
			if (*format >= '0' && *format <= '9') {
				for (precision = 0; *format >= '0' && *format <= '9'; )
					precision = 10 * precision + *format++ - '0';
			} else if (*format == '*') {
				precision = va_arg(val, int);
  2002f1:	89 c3                	mov    %eax,%ebx
				++format;
			}
			if (precision < 0)
  2002f3:	85 f6                	test   %esi,%esi
  2002f5:	79 08                	jns    2002ff <console_vprintf+0x10c>
  2002f7:	eb 04                	jmp    2002fd <console_vprintf+0x10a>
		}

		// process precision
		precision = -1;
		if (*format == '.') {
			++format;
  2002f9:	89 44 24 58          	mov    %eax,0x58(%esp)
			} else if (*format == '*') {
				precision = va_arg(val, int);
				++format;
			}
			if (precision < 0)
				precision = 0;
  2002fd:	31 f6                	xor    %esi,%esi
		}

		// process main conversion character
		negative = 0;
		numeric = 0;
		switch (*format) {
  2002ff:	8b 44 24 58          	mov    0x58(%esp),%eax
  200303:	8a 00                	mov    (%eax),%al
  200305:	3c 64                	cmp    $0x64,%al
  200307:	74 46                	je     20034f <console_vprintf+0x15c>
  200309:	7f 26                	jg     200331 <console_vprintf+0x13e>
  20030b:	3c 58                	cmp    $0x58,%al
  20030d:	0f 84 9f 00 00 00    	je     2003b2 <console_vprintf+0x1bf>
  200313:	3c 63                	cmp    $0x63,%al
  200315:	0f 84 c2 00 00 00    	je     2003dd <console_vprintf+0x1ea>
  20031b:	3c 43                	cmp    $0x43,%al
  20031d:	0f 85 ca 00 00 00    	jne    2003ed <console_vprintf+0x1fa>
		}
		case 's':
			data = va_arg(val, char *);
			break;
		case 'C':
			color = va_arg(val, int);
  200323:	8b 03                	mov    (%ebx),%eax
  200325:	83 c3 04             	add    $0x4,%ebx
  200328:	89 44 24 54          	mov    %eax,0x54(%esp)
			goto done;
  20032c:	e9 54 02 00 00       	jmp    200585 <console_vprintf+0x392>
		}

		// process main conversion character
		negative = 0;
		numeric = 0;
		switch (*format) {
  200331:	3c 75                	cmp    $0x75,%al
  200333:	74 58                	je     20038d <console_vprintf+0x19a>
  200335:	3c 78                	cmp    $0x78,%al
  200337:	74 69                	je     2003a2 <console_vprintf+0x1af>
  200339:	3c 73                	cmp    $0x73,%al
  20033b:	0f 85 ac 00 00 00    	jne    2003ed <console_vprintf+0x1fa>
			data = fill_numbuf(numbuf + NUMBUFSIZ, x, 16, upper_digits, precision);
			numeric = 1;
			break;
		}
		case 's':
			data = va_arg(val, char *);
  200341:	8b 03                	mov    (%ebx),%eax
  200343:	83 c3 04             	add    $0x4,%ebx
  200346:	89 44 24 08          	mov    %eax,0x8(%esp)
  20034a:	e9 bc 00 00 00       	jmp    20040b <console_vprintf+0x218>
		// process main conversion character
		negative = 0;
		numeric = 0;
		switch (*format) {
		case 'd': {
			int x = va_arg(val, int);
  20034f:	8d 7b 04             	lea    0x4(%ebx),%edi
  200352:	8b 1b                	mov    (%ebx),%ebx
			data = fill_numbuf(numbuf + NUMBUFSIZ, x > 0 ? x : -x, 10, upper_digits, precision);
  200354:	b9 0a 00 00 00       	mov    $0xa,%ecx
  200359:	89 74 24 04          	mov    %esi,0x4(%esp)
  20035d:	c7 04 24 20 06 20 00 	movl   $0x200620,(%esp)
  200364:	89 d8                	mov    %ebx,%eax
  200366:	c1 f8 1f             	sar    $0x1f,%eax
  200369:	89 c2                	mov    %eax,%edx
  20036b:	31 da                	xor    %ebx,%edx
  20036d:	29 c2                	sub    %eax,%edx
  20036f:	8d 44 24 3c          	lea    0x3c(%esp),%eax
  200373:	e8 a7 fd ff ff       	call   20011f <fill_numbuf>
			if (x < 0)
				negative = 1;
  200378:	c1 eb 1f             	shr    $0x1f,%ebx
  20037b:	89 d9                	mov    %ebx,%ecx
		// process main conversion character
		negative = 0;
		numeric = 0;
		switch (*format) {
		case 'd': {
			int x = va_arg(val, int);
  20037d:	89 fb                	mov    %edi,%ebx
			data = fill_numbuf(numbuf + NUMBUFSIZ, x > 0 ? x : -x, 10, upper_digits, precision);
			if (x < 0)
				negative = 1;
			numeric = 1;
  20037f:	bf 01 00 00 00       	mov    $0x1,%edi
		negative = 0;
		numeric = 0;
		switch (*format) {
		case 'd': {
			int x = va_arg(val, int);
			data = fill_numbuf(numbuf + NUMBUFSIZ, x > 0 ? x : -x, 10, upper_digits, precision);
  200384:	89 44 24 08          	mov    %eax,0x8(%esp)
  200388:	e9 82 00 00 00       	jmp    20040f <console_vprintf+0x21c>
				negative = 1;
			numeric = 1;
			break;
		}
		case 'u': {
			unsigned x = va_arg(val, unsigned);
  20038d:	8d 7b 04             	lea    0x4(%ebx),%edi
			data = fill_numbuf(numbuf + NUMBUFSIZ, x, 10, upper_digits, precision);
  200390:	b9 0a 00 00 00       	mov    $0xa,%ecx
  200395:	89 74 24 04          	mov    %esi,0x4(%esp)
  200399:	c7 04 24 20 06 20 00 	movl   $0x200620,(%esp)
  2003a0:	eb 23                	jmp    2003c5 <console_vprintf+0x1d2>
			numeric = 1;
			break;
		}
		case 'x': {
			unsigned x = va_arg(val, unsigned);
  2003a2:	8d 7b 04             	lea    0x4(%ebx),%edi
			data = fill_numbuf(numbuf + NUMBUFSIZ, x, 16, lower_digits, precision);
  2003a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  2003a9:	c7 04 24 0c 06 20 00 	movl   $0x20060c,(%esp)
  2003b0:	eb 0e                	jmp    2003c0 <console_vprintf+0x1cd>
			numeric = 1;
			break;
		}
		case 'X': {
			unsigned x = va_arg(val, unsigned);
  2003b2:	8d 7b 04             	lea    0x4(%ebx),%edi
			data = fill_numbuf(numbuf + NUMBUFSIZ, x, 16, upper_digits, precision);
  2003b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  2003b9:	c7 04 24 20 06 20 00 	movl   $0x200620,(%esp)
  2003c0:	b9 10 00 00 00       	mov    $0x10,%ecx
  2003c5:	8b 13                	mov    (%ebx),%edx
  2003c7:	8d 44 24 3c          	lea    0x3c(%esp),%eax
			data = fill_numbuf(numbuf + NUMBUFSIZ, x, 16, lower_digits, precision);
			numeric = 1;
			break;
		}
		case 'X': {
			unsigned x = va_arg(val, unsigned);
  2003cb:	89 fb                	mov    %edi,%ebx
			data = fill_numbuf(numbuf + NUMBUFSIZ, x, 16, upper_digits, precision);
			numeric = 1;
  2003cd:	bf 01 00 00 00       	mov    $0x1,%edi
			numeric = 1;
			break;
		}
		case 'X': {
			unsigned x = va_arg(val, unsigned);
			data = fill_numbuf(numbuf + NUMBUFSIZ, x, 16, upper_digits, precision);
  2003d2:	e8 48 fd ff ff       	call   20011f <fill_numbuf>
  2003d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  2003db:	eb 30                	jmp    20040d <console_vprintf+0x21a>
		case 'C':
			color = va_arg(val, int);
			goto done;
		case 'c':
			data = numbuf;
			numbuf[0] = va_arg(val, int);
  2003dd:	8b 03                	mov    (%ebx),%eax
  2003df:	83 c3 04             	add    $0x4,%ebx
			numbuf[1] = '\0';
  2003e2:	c6 44 24 29 00       	movb   $0x0,0x29(%esp)
		case 'C':
			color = va_arg(val, int);
			goto done;
		case 'c':
			data = numbuf;
			numbuf[0] = va_arg(val, int);
  2003e7:	88 44 24 28          	mov    %al,0x28(%esp)
  2003eb:	eb 16                	jmp    200403 <console_vprintf+0x210>
			numbuf[1] = '\0';
			break;
		normal:
		default:
			data = numbuf;
			numbuf[0] = (*format ? *format : '%');
  2003ed:	b2 25                	mov    $0x25,%dl
  2003ef:	84 c0                	test   %al,%al
  2003f1:	0f 45 d0             	cmovne %eax,%edx
  2003f4:	88 54 24 28          	mov    %dl,0x28(%esp)
			numbuf[1] = '\0';
  2003f8:	c6 44 24 29 00       	movb   $0x0,0x29(%esp)
			if (!*format)
  2003fd:	75 04                	jne    200403 <console_vprintf+0x210>
				format--;
  2003ff:	ff 4c 24 58          	decl   0x58(%esp)
			numbuf[0] = va_arg(val, int);
			numbuf[1] = '\0';
			break;
		normal:
		default:
			data = numbuf;
  200403:	8d 44 24 28          	lea    0x28(%esp),%eax
  200407:	89 44 24 08          	mov    %eax,0x8(%esp)
				precision = 0;
		}

		// process main conversion character
		negative = 0;
		numeric = 0;
  20040b:	31 ff                	xor    %edi,%edi
			if (precision < 0)
				precision = 0;
		}

		// process main conversion character
		negative = 0;
  20040d:	31 c9                	xor    %ecx,%ecx
			if (!*format)
				format--;
			break;
		}

		if (precision >= 0)
  20040f:	83 fe ff             	cmp    $0xffffffff,%esi
  200412:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  200416:	74 12                	je     20042a <console_vprintf+0x237>
			len = strnlen(data, precision);
  200418:	8b 44 24 08          	mov    0x8(%esp),%eax
  20041c:	89 74 24 04          	mov    %esi,0x4(%esp)
  200420:	89 04 24             	mov    %eax,(%esp)
  200423:	e8 b5 fd ff ff       	call   2001dd <strnlen>
  200428:	eb 0c                	jmp    200436 <console_vprintf+0x243>
		else
			len = strlen(data);
  20042a:	8b 44 24 08          	mov    0x8(%esp),%eax
  20042e:	89 04 24             	mov    %eax,(%esp)
  200431:	e8 97 fd ff ff       	call   2001cd <strlen>
  200436:	8b 4c 24 18          	mov    0x18(%esp),%ecx
		if (numeric && negative)
			negative = '-';
  20043a:	ba 2d 00 00 00       	mov    $0x2d,%edx
		}

		if (precision >= 0)
			len = strnlen(data, precision);
		else
			len = strlen(data);
  20043f:	89 44 24 10          	mov    %eax,0x10(%esp)
		if (numeric && negative)
  200443:	89 f8                	mov    %edi,%eax
  200445:	83 e0 01             	and    $0x1,%eax
  200448:	88 44 24 18          	mov    %al,0x18(%esp)
  20044c:	89 f8                	mov    %edi,%eax
  20044e:	84 c8                	test   %cl,%al
  200450:	75 17                	jne    200469 <console_vprintf+0x276>
			negative = '-';
		else if (flags & FLAG_PLUSPOSITIVE)
  200452:	f6 44 24 14 10       	testb  $0x10,0x14(%esp)
			negative = '+';
  200457:	b2 2b                	mov    $0x2b,%dl
			len = strnlen(data, precision);
		else
			len = strlen(data);
		if (numeric && negative)
			negative = '-';
		else if (flags & FLAG_PLUSPOSITIVE)
  200459:	75 0e                	jne    200469 <console_vprintf+0x276>
			negative = '+';
		else if (flags & FLAG_SPACEPOSITIVE)
			negative = ' ';
  20045b:	8b 44 24 14          	mov    0x14(%esp),%eax
  20045f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  200466:	83 e2 20             	and    $0x20,%edx
		else
			negative = 0;
		if (numeric && precision > len)
  200469:	3b 74 24 10          	cmp    0x10(%esp),%esi
  20046d:	7e 0f                	jle    20047e <console_vprintf+0x28b>
  20046f:	80 7c 24 18 00       	cmpb   $0x0,0x18(%esp)
  200474:	74 08                	je     20047e <console_vprintf+0x28b>
			zeros = precision - len;
  200476:	2b 74 24 10          	sub    0x10(%esp),%esi
  20047a:	89 f7                	mov    %esi,%edi
  20047c:	eb 3a                	jmp    2004b8 <console_vprintf+0x2c5>
		else if ((flags & (FLAG_ZERO | FLAG_LEFTJUSTIFY)) == FLAG_ZERO
  20047e:	8b 4c 24 14          	mov    0x14(%esp),%ecx
			 && numeric && precision < 0
			 && len + !!negative < width)
			zeros = width - len - !!negative;
		else
			zeros = 0;
  200482:	31 ff                	xor    %edi,%edi
			negative = ' ';
		else
			negative = 0;
		if (numeric && precision > len)
			zeros = precision - len;
		else if ((flags & (FLAG_ZERO | FLAG_LEFTJUSTIFY)) == FLAG_ZERO
  200484:	83 e1 06             	and    $0x6,%ecx
  200487:	83 f9 02             	cmp    $0x2,%ecx
  20048a:	75 2c                	jne    2004b8 <console_vprintf+0x2c5>
			 && numeric && precision < 0
  20048c:	80 7c 24 18 00       	cmpb   $0x0,0x18(%esp)
  200491:	74 23                	je     2004b6 <console_vprintf+0x2c3>
  200493:	c1 ee 1f             	shr    $0x1f,%esi
  200496:	74 1e                	je     2004b6 <console_vprintf+0x2c3>
			 && len + !!negative < width)
  200498:	8b 74 24 10          	mov    0x10(%esp),%esi
  20049c:	31 c0                	xor    %eax,%eax
  20049e:	85 d2                	test   %edx,%edx
  2004a0:	0f 95 c0             	setne  %al
  2004a3:	8d 0c 06             	lea    (%esi,%eax,1),%ecx
  2004a6:	3b 4c 24 0c          	cmp    0xc(%esp),%ecx
  2004aa:	7d 0c                	jge    2004b8 <console_vprintf+0x2c5>
			zeros = width - len - !!negative;
  2004ac:	8b 7c 24 0c          	mov    0xc(%esp),%edi
  2004b0:	29 f7                	sub    %esi,%edi
  2004b2:	29 c7                	sub    %eax,%edi
  2004b4:	eb 02                	jmp    2004b8 <console_vprintf+0x2c5>
		else
			zeros = 0;
  2004b6:	31 ff                	xor    %edi,%edi
		width -= len + zeros + !!negative;
  2004b8:	8b 74 24 10          	mov    0x10(%esp),%esi
  2004bc:	85 d2                	test   %edx,%edx
  2004be:	0f 95 c0             	setne  %al
  2004c1:	0f b6 c8             	movzbl %al,%ecx
  2004c4:	01 fe                	add    %edi,%esi
  2004c6:	01 f1                	add    %esi,%ecx
  2004c8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  2004cc:	29 ce                	sub    %ecx,%esi
	if (c == '\n') {
		int pos = (cursor - CONSOLE_BEGIN) % 80;
		for (; pos != 80; pos++)
			*cursor++ = ' ' | color;
	} else
		*cursor++ = c | color;
  2004ce:	8b 4c 24 54          	mov    0x54(%esp),%ecx
  2004d2:	83 c9 20             	or     $0x20,%ecx
			 && len + !!negative < width)
			zeros = width - len - !!negative;
		else
			zeros = 0;
		width -= len + zeros + !!negative;
		for (; !(flags & FLAG_LEFTJUSTIFY) && width > 0; --width)
  2004d5:	f6 44 24 14 04       	testb  $0x4,0x14(%esp)
	if (c == '\n') {
		int pos = (cursor - CONSOLE_BEGIN) % 80;
		for (; pos != 80; pos++)
			*cursor++ = ' ' | color;
	} else
		*cursor++ = c | color;
  2004da:	66 89 4c 24 0c       	mov    %cx,0xc(%esp)
			 && len + !!negative < width)
			zeros = width - len - !!negative;
		else
			zeros = 0;
		width -= len + zeros + !!negative;
		for (; !(flags & FLAG_LEFTJUSTIFY) && width > 0; --width)
  2004df:	74 13                	je     2004f4 <console_vprintf+0x301>
			cursor = console_putc(cursor, ' ', color);
		if (negative)
  2004e1:	84 c0                	test   %al,%al
  2004e3:	74 2f                	je     200514 <console_vprintf+0x321>
			cursor = console_putc(cursor, negative, color);
  2004e5:	8b 4c 24 54          	mov    0x54(%esp),%ecx
  2004e9:	89 e8                	mov    %ebp,%eax
  2004eb:	e8 e2 fb ff ff       	call   2000d2 <console_putc>
  2004f0:	89 c5                	mov    %eax,%ebp
  2004f2:	eb 20                	jmp    200514 <console_vprintf+0x321>
			 && len + !!negative < width)
			zeros = width - len - !!negative;
		else
			zeros = 0;
		width -= len + zeros + !!negative;
		for (; !(flags & FLAG_LEFTJUSTIFY) && width > 0; --width)
  2004f4:	85 f6                	test   %esi,%esi
  2004f6:	7e e9                	jle    2004e1 <console_vprintf+0x2ee>

static uint16_t *
console_putc(uint16_t *cursor, unsigned char c, int color)
{
	if (cursor >= CONSOLE_END)
		cursor = CONSOLE_BEGIN;
  2004f8:	81 fd a0 8f 0b 00    	cmp    $0xb8fa0,%ebp
  2004fe:	b9 00 80 0b 00       	mov    $0xb8000,%ecx
  200503:	0f 43 e9             	cmovae %ecx,%ebp
	if (c == '\n') {
		int pos = (cursor - CONSOLE_BEGIN) % 80;
		for (; pos != 80; pos++)
			*cursor++ = ' ' | color;
	} else
		*cursor++ = c | color;
  200506:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
			 && len + !!negative < width)
			zeros = width - len - !!negative;
		else
			zeros = 0;
		width -= len + zeros + !!negative;
		for (; !(flags & FLAG_LEFTJUSTIFY) && width > 0; --width)
  20050a:	4e                   	dec    %esi
			cursor = console_putc(cursor, ' ', color);
  20050b:	83 c5 02             	add    $0x2,%ebp
	if (c == '\n') {
		int pos = (cursor - CONSOLE_BEGIN) % 80;
		for (; pos != 80; pos++)
			*cursor++ = ' ' | color;
	} else
		*cursor++ = c | color;
  20050e:	66 89 4d fe          	mov    %cx,-0x2(%ebp)
  200512:	eb e0                	jmp    2004f4 <console_vprintf+0x301>
  200514:	8b 54 24 54          	mov    0x54(%esp),%edx

static uint16_t *
console_putc(uint16_t *cursor, unsigned char c, int color)
{
	if (cursor >= CONSOLE_END)
		cursor = CONSOLE_BEGIN;
  200518:	b8 00 80 0b 00       	mov    $0xb8000,%eax
	if (c == '\n') {
		int pos = (cursor - CONSOLE_BEGIN) % 80;
		for (; pos != 80; pos++)
			*cursor++ = ' ' | color;
	} else
		*cursor++ = c | color;
  20051d:	83 ca 30             	or     $0x30,%edx
		width -= len + zeros + !!negative;
		for (; !(flags & FLAG_LEFTJUSTIFY) && width > 0; --width)
			cursor = console_putc(cursor, ' ', color);
		if (negative)
			cursor = console_putc(cursor, negative, color);
		for (; zeros > 0; --zeros)
  200520:	85 ff                	test   %edi,%edi
  200522:	7e 13                	jle    200537 <console_vprintf+0x344>

static uint16_t *
console_putc(uint16_t *cursor, unsigned char c, int color)
{
	if (cursor >= CONSOLE_END)
		cursor = CONSOLE_BEGIN;
  200524:	81 fd a0 8f 0b 00    	cmp    $0xb8fa0,%ebp
  20052a:	0f 43 e8             	cmovae %eax,%ebp
		width -= len + zeros + !!negative;
		for (; !(flags & FLAG_LEFTJUSTIFY) && width > 0; --width)
			cursor = console_putc(cursor, ' ', color);
		if (negative)
			cursor = console_putc(cursor, negative, color);
		for (; zeros > 0; --zeros)
  20052d:	4f                   	dec    %edi
	if (c == '\n') {
		int pos = (cursor - CONSOLE_BEGIN) % 80;
		for (; pos != 80; pos++)
			*cursor++ = ' ' | color;
	} else
		*cursor++ = c | color;
  20052e:	66 89 55 00          	mov    %dx,0x0(%ebp)
		for (; !(flags & FLAG_LEFTJUSTIFY) && width > 0; --width)
			cursor = console_putc(cursor, ' ', color);
		if (negative)
			cursor = console_putc(cursor, negative, color);
		for (; zeros > 0; --zeros)
			cursor = console_putc(cursor, '0', color);
  200532:	83 c5 02             	add    $0x2,%ebp
  200535:	eb e9                	jmp    200520 <console_vprintf+0x32d>
		width -= len + zeros + !!negative;
		for (; !(flags & FLAG_LEFTJUSTIFY) && width > 0; --width)
			cursor = console_putc(cursor, ' ', color);
		if (negative)
			cursor = console_putc(cursor, negative, color);
		for (; zeros > 0; --zeros)
  200537:	8b 7c 24 08          	mov    0x8(%esp),%edi
  20053b:	8b 44 24 10          	mov    0x10(%esp),%eax
  20053f:	01 f8                	add    %edi,%eax
  200541:	89 44 24 08          	mov    %eax,0x8(%esp)
  200545:	8b 44 24 08          	mov    0x8(%esp),%eax
  200549:	29 f8                	sub    %edi,%eax
			cursor = console_putc(cursor, '0', color);
		for (; len > 0; ++data, --len)
  20054b:	85 c0                	test   %eax,%eax
  20054d:	7e 13                	jle    200562 <console_vprintf+0x36f>
			cursor = console_putc(cursor, *data, color);
  20054f:	0f b6 17             	movzbl (%edi),%edx
  200552:	89 e8                	mov    %ebp,%eax
			cursor = console_putc(cursor, ' ', color);
		if (negative)
			cursor = console_putc(cursor, negative, color);
		for (; zeros > 0; --zeros)
			cursor = console_putc(cursor, '0', color);
		for (; len > 0; ++data, --len)
  200554:	47                   	inc    %edi
			cursor = console_putc(cursor, *data, color);
  200555:	8b 4c 24 54          	mov    0x54(%esp),%ecx
  200559:	e8 74 fb ff ff       	call   2000d2 <console_putc>
  20055e:	89 c5                	mov    %eax,%ebp
  200560:	eb e3                	jmp    200545 <console_vprintf+0x352>
	if (c == '\n') {
		int pos = (cursor - CONSOLE_BEGIN) % 80;
		for (; pos != 80; pos++)
			*cursor++ = ' ' | color;
	} else
		*cursor++ = c | color;
  200562:	8b 54 24 54          	mov    0x54(%esp),%edx

static uint16_t *
console_putc(uint16_t *cursor, unsigned char c, int color)
{
	if (cursor >= CONSOLE_END)
		cursor = CONSOLE_BEGIN;
  200566:	b8 00 80 0b 00       	mov    $0xb8000,%eax
	if (c == '\n') {
		int pos = (cursor - CONSOLE_BEGIN) % 80;
		for (; pos != 80; pos++)
			*cursor++ = ' ' | color;
	} else
		*cursor++ = c | color;
  20056b:	83 ca 20             	or     $0x20,%edx
			cursor = console_putc(cursor, negative, color);
		for (; zeros > 0; --zeros)
			cursor = console_putc(cursor, '0', color);
		for (; len > 0; ++data, --len)
			cursor = console_putc(cursor, *data, color);
		for (; width > 0; --width)
  20056e:	85 f6                	test   %esi,%esi
  200570:	7e 13                	jle    200585 <console_vprintf+0x392>

static uint16_t *
console_putc(uint16_t *cursor, unsigned char c, int color)
{
	if (cursor >= CONSOLE_END)
		cursor = CONSOLE_BEGIN;
  200572:	81 fd a0 8f 0b 00    	cmp    $0xb8fa0,%ebp
  200578:	0f 43 e8             	cmovae %eax,%ebp
			cursor = console_putc(cursor, negative, color);
		for (; zeros > 0; --zeros)
			cursor = console_putc(cursor, '0', color);
		for (; len > 0; ++data, --len)
			cursor = console_putc(cursor, *data, color);
		for (; width > 0; --width)
  20057b:	4e                   	dec    %esi
	if (c == '\n') {
		int pos = (cursor - CONSOLE_BEGIN) % 80;
		for (; pos != 80; pos++)
			*cursor++ = ' ' | color;
	} else
		*cursor++ = c | color;
  20057c:	66 89 55 00          	mov    %dx,0x0(%ebp)
		for (; zeros > 0; --zeros)
			cursor = console_putc(cursor, '0', color);
		for (; len > 0; ++data, --len)
			cursor = console_putc(cursor, *data, color);
		for (; width > 0; --width)
			cursor = console_putc(cursor, ' ', color);
  200580:	83 c5 02             	add    $0x2,%ebp
  200583:	eb e9                	jmp    20056e <console_vprintf+0x37b>
	int flags, width, zeros, precision, negative, numeric, len;
#define NUMBUFSIZ 20
	char numbuf[NUMBUFSIZ];
	char *data;

	for (; *format; ++format) {
  200585:	ff 44 24 58          	incl   0x58(%esp)
  200589:	e9 74 fc ff ff       	jmp    200202 <console_vprintf+0xf>
			const char *flagc = flag_chars;
			while (*flagc != '\0' && *flagc != *format)
				++flagc;
			if (*flagc == '\0')
				break;
			flags |= (1 << (flagc - flag_chars));
  20058e:	81 e9 04 06 20 00    	sub    $0x200604,%ecx
  200594:	89 f0                	mov    %esi,%eax
  200596:	d3 e0                	shl    %cl,%eax
			continue;
		}

		// process flags
		flags = 0;
		for (++format; *format; ++format) {
  200598:	ff 44 24 58          	incl   0x58(%esp)
			const char *flagc = flag_chars;
			while (*flagc != '\0' && *flagc != *format)
				++flagc;
			if (*flagc == '\0')
				break;
			flags |= (1 << (flagc - flag_chars));
  20059c:	09 44 24 14          	or     %eax,0x14(%esp)
  2005a0:	e9 94 fc ff ff       	jmp    200239 <console_vprintf+0x46>
			cursor = console_putc(cursor, ' ', color);
	done: ;
	}

	return cursor;
}
  2005a5:	83 c4 3c             	add    $0x3c,%esp
  2005a8:	89 e8                	mov    %ebp,%eax
  2005aa:	5b                   	pop    %ebx
  2005ab:	5e                   	pop    %esi
  2005ac:	5f                   	pop    %edi
  2005ad:	5d                   	pop    %ebp
  2005ae:	c3                   	ret    

002005af <console_printf>:

uint16_t *
console_printf(uint16_t *cursor, int color, const char *format, ...)
{
  2005af:	83 ec 10             	sub    $0x10,%esp
	va_list val;
	va_start(val, format);
	cursor = console_vprintf(cursor, color, format, val);
  2005b2:	8d 44 24 20          	lea    0x20(%esp),%eax
  2005b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  2005ba:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  2005be:	89 44 24 08          	mov    %eax,0x8(%esp)
  2005c2:	8b 44 24 18          	mov    0x18(%esp),%eax
  2005c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  2005ca:	8b 44 24 14          	mov    0x14(%esp),%eax
  2005ce:	89 04 24             	mov    %eax,(%esp)
  2005d1:	e8 1d fc ff ff       	call   2001f3 <console_vprintf>
	va_end(val);
	return cursor;
}
  2005d6:	83 c4 10             	add    $0x10,%esp
  2005d9:	c3                   	ret    
