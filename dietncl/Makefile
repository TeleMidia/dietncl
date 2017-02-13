MODULES= glib-2.0 lua5.2
CFLAGS= -Wall -g -O0 -fpic `pkg-config --cflags $(MODULES)`
LDFLAGS= `pkg-config --libs $(MODULES)`

all: xmllib.so

xmllib.so: xmllib.o
	$(CC) $(CFLAGS) $(LDFLAGS) -shared -o $@ $<

clean:
	-rm -f *.o *.so
