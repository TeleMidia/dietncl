/* This code needs to be called recursively by lua in order for the
   tables to be set appropriately */
/* Call the dump function inside the code for debugging */
/* Define the properties inside a table that goes in the 0 key */
/* The comments could be passed back to lua as a table with the key
   'comments' inside the table where the comment was made */

#include <glib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <lua.h>
#include <lauxlib.h>

gchar *current_animal_noise = NULL;

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

/* Code to grab the file into memory and parse it */
static gboolean G_GNUC_UNUSED parse_file (const char *file, lua_State *L) {
  char *text;
  gsize length;
  GMarkupParseContext *context =  g_markup_parse_context_new (&parser, 0,
                                                              L, NULL);

  lua_newtable (L);
  lua_pushvalue (L, -1);
  lua_pushinteger (L, -1);

  if (g_file_get_contents (file, &text, &length, NULL) == FALSE) {
    printf("Couldn't load XML\n");
    return FALSE;
  }

  if (g_markup_parse_context_parse (context, text, length, NULL) == FALSE) {
    printf("Parse failed\n");
    return FALSE;
  }

  g_free(text);
  g_markup_parse_context_free (context);
  return TRUE;

}

static void dump (lua_State *L) {
  int n = lua_gettop (L);
  int i = 0;
  int c;
  for (i=1; i<=n; i++) {
    c = lua_type (L, i);
    switch (c) {
    case LUA_TNIL:
      printf ("NIL\n");
      break;
    case LUA_TNUMBER:
    case LUA_TSTRING:
      printf ("%s\n", lua_tostring (L, i));
      break;
    case LUA_TBOOLEAN:
      if (lua_toboolean (L, i) == 0)
        printf ("FALSE\n");
      else
        printf ("TRUE\n");
      break;
    case LUA_TTABLE:
    case LUA_TFUNCTION:
    case LUA_TUSERDATA:
      printf ("%p\n", lua_topointer(L, i));
      break;
    }
  }
}

static int l_parse_file (lua_State *L) {
  const char *str = luaL_checkstring (L, 1);
  parse_file (str, L);
  dump (L);
  return 1;
}

int luaopen_simple2 (lua_State *L) {
  lua_pushcfunction (L, l_parse_file);
  return 1;
}
