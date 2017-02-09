/* This code needs to be called recursively by lua in order for the
   tables to be set appropriately */
/* The comments could be passed back to lua as a table with the key
   'comments' inside the table where the comment was made */

#include <glib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <lua.h>
#include <lauxlib.h>

/* The handler functions. */
static void start_element (GMarkupParseContext *context,
                           const gchar         *elt,
                           const gchar        **names,
                           const gchar        **values,
                           gpointer             data,
                           GError             **error) {

  lua_State* L = (lua_State*) data;
  gsize index;

  index = lua_tointeger (L, -1) + 1;
  lua_pop (L, 1);
  lua_pushinteger (L, index);

  if (lua_tointeger (L, -1) > 0) {
    lua_newtable (L);
    lua_pushvalue (L, -3);
    lua_pushvalue (L, -3);
    lua_pushvalue (L, -3);
    lua_rawset (L, -3);
    lua_pop (L, 1);
    lua_pushinteger (L, 0);
    index = lua_tointeger (L, -1);
  }

  lua_pushstring (L, elt);
  lua_rawset (L, -3);

  while (*names != NULL) {

    lua_pushstring (L, *names);
    lua_pushstring (L, *values);
    lua_rawset (L, -3);
    names++;
    values++;
  }

  lua_pushinteger (L, index);
}

static void text(GMarkupParseContext *context,
    const gchar         *text,
    gsize                text_len,
    gpointer             data,
    GError             **error) {
}

static void end_element (GMarkupParseContext *context,
    const gchar         *elt,
    gpointer             data,
    GError             **error) {

  lua_State* L = (lua_State*) data;

  lua_pop (L, 2);
}

/* The list of what handler does what. */
static GMarkupParser parser = {
  start_element,
  end_element,
  text,
  NULL,
  NULL
};

static void dump (lua_State *L) {
  int n = lua_gettop (L);
  int i = 0;
  int c;
  for (i=1; i<=n; i++) {
    c = lua_type (L, i);
    switch (c) {
    case LUA_TNIL:
      printf ("#%d: NIL\n", i);
      break;
    case LUA_TNUMBER:
    case LUA_TSTRING:
      printf ("#%d: %s\n", i, lua_tostring (L, i));
      break;
    case LUA_TBOOLEAN:
      if (lua_toboolean (L, i) == 0)
        printf ("#%d: FALSE\n", i);
      else
        printf ("#%d: TRUE\n", i);
      break;
    case LUA_TTABLE:
    case LUA_TFUNCTION:
    case LUA_TUSERDATA:
      printf ("#%d: %p\n", i, lua_topointer(L, i));
      break;
    }
  }
}

/* Parses XML string */
static int l_parse_string (lua_State *L) {
  gsize length;
  const char *text = lua_tolstring (L, -1, &length);
  GMarkupParseContext *context =  g_markup_parse_context_new (&parser, 0,
                                                              L, NULL);

  lua_newtable (L);
  lua_pushvalue (L, -1);
  lua_pushinteger (L, -1);

  if (g_markup_parse_context_parse (context, text, length, NULL) == FALSE) {
    g_markup_parse_context_free (context);
    lua_pushliteral (L, "Parse failed");
    return lua_error (L);
  }

  g_markup_parse_context_free (context);

  return 1;
}

/* Load XML file */
static int l_parse_file (lua_State *L) {
  const char *str = luaL_checkstring (L, 1);
  char *text;
  gsize length;

  if (g_file_get_contents (str, &text, &length, NULL) == FALSE) {
    lua_pushliteral (L, "Couldn't load XML");
    return lua_error (L);
  }

  lua_pushlstring (L, text, length);

  l_parse_string (L);

  g_free(text);
  dump (L);
  return 1;
}

static const struct luaL_Reg funcs[] = {
  {"parse_file", l_parse_file},
  {"parse_string", l_parse_string},
  {NULL, NULL}
};

int luaopen_dietncl_xmllib (lua_State *L) {
  luaL_newlib (L, funcs);
  return 1;
}
