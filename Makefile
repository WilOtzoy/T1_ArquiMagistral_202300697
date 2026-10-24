
AS = aarch64-linux-gnu-as
LD = aarch64-linux-gnu-ld
QEMU = qemu-aarch64

SRC = src/main.s
OBJ = src/main.o
TARGET = programa

ASFLAGS = -g

.PHONY: all run clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(AS) $(ASFLAGS) -o $(OBJ) $(SRC)

$(TARGET): $(OBJ)
	$(LD) -o $(TARGET) $(OBJ)

run: $(TARGET)
	$(QEMU) ./$(TARGET)

clean:
	rm -f $(OBJ) $(TARGET)
