MODULES= glib-2.0 lua5.2
CFLAGS= -Wall -fpic `pkg-config --cflags $(MODULES)`
LDFLAGS= `pkg-config --libs $(MODULES)`

all: simple2.so

simple2.so: simple2.o
	$(CC) $(CFLAGS) $(LDFLAGS) -shared -o $@ $<

clean:
	-rm -f *.o *.so

# final: test.c libsimple.so simple.xml
# 	gcc -L. -Wl,-rpath=. -Wall -o out test.c `pkg-config --cflags --libs glib-2.0 lua5.2` -lsimple
# 	./out simple.xml simple2.xml
#run with lua command instead of gcc

# libsimple.so: simple.o
# 	gcc -shared -o libsimple.so simple.o

# simple.o: simple.c
# 	gcc -c -Wall -fpic simple.c `pkg-config --cflags --libs glib-2.0`

# clean:
# 	rm -f simple.o
# 	rm -f libsimple.so
# 	rm -f out
