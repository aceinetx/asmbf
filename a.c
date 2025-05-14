#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

typedef unsigned char byte;
typedef unsigned long dword;

byte* readFile(const char* filename, dword* outSize) {
	int fd;
	struct stat fileStat;
	byte* buffer;
	ssize_t bytesRead;

	if (outSize) {
		*outSize = (dword)-1;
	}

	// Open the file
	fd = open(filename, O_RDONLY);
	if (fd == -1) {
		return NULL; // Failed to open the file
	}

	// Get the file size
	if (fstat(fd, &fileStat) == -1) {
		close(fd);
		return NULL; // Failed to get file status
	}

	long fileSize = fileStat.st_size;
	if (fileSize < 0) {
		close(fd);
		return NULL; // Invalid file size
	}

	// Allocate memory for the buffer
	buffer = (byte*)malloc(fileSize);
	if (!buffer) {
		close(fd);
		return NULL; // Memory allocation failed
	}

	// Read the file into the buffer
	bytesRead = read(fd, buffer, fileSize);
	if (bytesRead != fileSize) {
		free(buffer);
		close(fd);
		return NULL; // Failed to read the entire file
	}

	// Close the file descriptor
	close(fd);

	if (outSize) {
		*outSize = (dword)fileSize; // Set the output size
	}

	return buffer; // Return the buffer containing the file data
}

int main() {
	printf("%d\n", O_RDONLY);
	struct stat s;
	printf("%d\n", sizeof(struct stat));
	printf("%p\n", (void*)&(s.st_size) - (void*)&s);
	printf("%d\n", PROT_READ | PROT_WRITE);
	printf("%d\n", MAP_PRIVATE);
	printf("%d\n", MAP_FAILED);
}
