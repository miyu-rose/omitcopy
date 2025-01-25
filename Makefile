SHELL=fish.x
AS=has060x
LK=hlkx

OBJ=TSRLIB.o omitcopy.o

all : omitcopy.x

omitcopy.x : $(OBJ)
	$(LK) -x -o$@ $(OBJ)

%.o : %.s
	$(AS) -u -w3 $<

clean :
	-rm *.o *.x *.*~ *.bak > NUL
