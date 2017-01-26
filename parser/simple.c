#include <glib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

gchar *current_animal_noise = NULL;

void identate (int n) {

  int i;

  for (i=0; i<n; i++)
    g_print("\t");
}

/* The handler functions. */

void start_element (GMarkupParseContext *context,
                    const gchar         *elt,
                    const gchar        **names,
                    const gchar        **values,
                    gpointer             data,
                    GError             **error) {

  int* level = (int*) data;
  identate (*level);
  (*level)++;

  g_print ("<%s", elt);

  while (*names != NULL)
    {
      g_print (" %s=%s", *names, *values);
      names++;
    }

  g_print (">\n");
}

void text(GMarkupParseContext *context,
    const gchar         *text,
    gsize                text_len,
    gpointer             data,
    GError             **error)
{
  int *level = (int*) data;
  gchar *comment;
  comment = g_strchomp (g_strndup (text, text_len));
  if (strlen (comment) > 0) {
    identate (*level);
    g_print ("%s\n", comment);
  }
}

void end_element (GMarkupParseContext *context,
    const gchar         *elt,
    gpointer             data,
    GError             **error)
{
  int *level = (int*) data;
  (*level)--;
  identate (*level);
  g_print ("</%s>\n", elt);
}

/* The list of what handler does what. */
static GMarkupParser parser = {
  start_element,
  end_element,
  text,
  NULL,
  NULL
};

/* Code to grab the file into memory and parse it. */
int main(int argc, char *argv[]) {
  char *text;
  gsize length;
  gsize level;
  GMarkupParseContext *context =  g_markup_parse_context_new (&parser, 0,
                                                              &level, NULL);

  /* seriously crummy error checking */
  int i;

  for (i=1; i<argc; i++) {

    level = 0;

    if (g_file_get_contents (argv[i], &text, &length, NULL) == FALSE) {
      printf("Couldn't load XML\n");
      exit(255);
    }

    if (g_markup_parse_context_parse (context, text, length, NULL) == FALSE) {
      printf("Parse failed\n");
      exit(255);
    }
  }

  g_free(text);
  g_markup_parse_context_free (context);


  return 0;
}
/* EOF */
