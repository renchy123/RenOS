.PHONY : all clean rebuild

SRC := boot.asm
OUT := boot.bin
IMG := data.img

RM  := rm -rf

all : $(OUT) $(IMG)
	dd if=$(OUT) of=$(IMG) bs=512 count=1 conv=notrunc
	@echo "Success !!!"

$(IMG) :
	bximage $@ -q -fd -size=1.44
	mkfs.vfat -F 12 $@

$(OUT) : $(SRC)
	nasm $^ -o  $@

clean :
	$(RM) $(IMG) $(OUT)

rebuild :
	@$(MAKE) clean
	@$(MAKE) all
