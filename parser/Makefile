MODULES= glib-2.0 lua5.2
CFLAGS= -Wall -fpic `pkg-config --cflags $(MODULES)`
LDFLAGS= `pkg-config --libs $(MODULES)`

all: simplelib.so

simplelib.so: simplelib.o
	$(CC) $(CFLAGS) $(LDFLAGS) -shared -o $@ $<

clean:
	-rm -f *.o *.so
