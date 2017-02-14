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

/* Registry key for the canvas metatable.  */
#define XML "dietncl.xml"


/* The handler functions. */
static void start_element (GMarkupParseContext *context,
                           const gchar         *elt,
                           const gchar        **names,
                           const gchar        **values,
                           gpointer             data,
                           GError             **error) {

  lua_State* L = (lua_State*) data;
  gsize index;
  gint line_n;
  gint char_n;

  g_markup_parse_context_get_position (context, &line_n, &char_n);

  index = lua_tointeger (L, -1) + 1;
  lua_pop (L, 1);
  lua_pushinteger (L, index);

  /* create and set element table*/
  lua_newtable (L);
  lua_pushvalue (L, -3);
  lua_pushvalue (L, -3);
  lua_pushvalue (L, -3);
  lua_rawset (L, -3);
  lua_pop (L, 1);

  if (index > 0) {
    /* set metatable */
    luaL_setmetatable (L, XML);

    /* create and set identification table */
    lua_pushinteger (L, 0);
    lua_newtable (L);
    lua_pushvalue (L, -3);
    lua_pushvalue (L, -3);
    lua_pushvalue (L, -3);
    lua_rawset (L, -3);
    lua_pop (L, 1);

    /* set parent */
    lua_pushstring (L, "parent");
    lua_pushvalue (L, -6);
    lua_rawset (L, -3);
  }

  /* set starting line and character */
  lua_pushstring (L, "start_line");
  lua_pushinteger (L, line_n);
  lua_rawset (L, -3);
  lua_pushstring (L, "start_char");
  lua_pushinteger (L, char_n);
  lua_rawset (L, -3);

  /* set tag */
  lua_pushstring (L, "tag");
  lua_pushstring (L, elt);
  lua_rawset (L, -3);
  lua_pop (L, 1);

  while (*names != NULL) {
    /* set element attributes */
    lua_pushstring (L, *names);
    lua_pushstring (L, *values);
    lua_rawset (L, -4);
    names++;
    values++;
  }
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
  gint line_n;
  gint char_n;

  g_markup_parse_context_get_position (context, &line_n, &char_n);

  /* get table at index 0 */
  lua_rawgeti (L, -2, 0);

  /* set ending line and character */
  lua_pushstring (L, "end_line");
  lua_pushinteger (L, line_n);
  lua_rawset (L, -3);
  lua_pushstring (L, "end_char");
  lua_pushinteger (L, char_n);
  lua_rawset (L, -3);

  /* end element */
  lua_pop (L, 3);
}

/* The list of what handler does what. */
static GMarkupParser parser = {
  start_element,
  end_element,
  text,
  NULL,
  NULL
};

static void G_GNUC_UNUSED dump (lua_State *L) {
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
  GMarkupParseContext *context;
  const char *text;
  gsize length;
  GError *error = NULL;

  context = g_markup_parse_context_new (&parser, 0, L, NULL);
  g_assert_nonnull (context);

  text = luaL_checklstring (L, -1, &length);
  g_assert_nonnull (text);

  lua_newtable (L);
  luaL_setmetatable (L, XML);
  lua_pushvalue (L, -1);
  lua_pushinteger (L, -1);

  if (!g_markup_parse_context_parse (context, text, length, &error))
    goto fail;

  if (!g_markup_parse_context_end_parse (context, &error))
    goto fail;

  g_markup_parse_context_free (context);
  return 1;

fail:
  g_markup_parse_context_free (context);
  lua_pushfstring (L, "parse string failed: %s", error->message);
  return lua_error (L);
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
  return 1;
}

static const struct luaL_Reg funcs[] = {
  {"parse_file", l_parse_file},
  {"parse_string", l_parse_string},
  {NULL, NULL}
};

int luaopen_dietncl_xmllib (lua_State *L) {
  g_assert (luaL_newmetatable (L, XML) != 0);
  lua_pushvalue (L, -1);
  lua_setfield (L, -2, "__index");
  /* lua_pushliteral (L, "not your business"); */
  /* lua_setfield (L, -2, "__metatable"); */
  luaL_setfuncs (L, funcs, 0);
  return 1;
}
