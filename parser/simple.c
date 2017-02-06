#include <glib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

gchar *current_animal_noise = NULL;

static void identate (int n) {

  int i;

  for (i=0; i<n; i++)
    g_print("\t");
}

/* The handler functions. */

static void start_element (GMarkupParseContext *context,
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

static void text(GMarkupParseContext *context,
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

static void end_element (GMarkupParseContext *context,
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

/* Code to grab the file into memory and parse it */
void parse_file (char *file) {
  char *text;
  gsize length;
  int level = 0;
  GMarkupParseContext *context =  g_markup_parse_context_new (&parser, 0,
                                                              &level, NULL);


  if (g_file_get_contents (file, &text, &length, NULL) == FALSE) {
    printf("Couldn't load XML\n");
    exit(255);
  }

  if (g_markup_parse_context_parse (context, text, length, NULL) == FALSE) {
    printf("Parse failed\n");
    exit(255);
  }

  g_free(text);

  g_markup_parse_context_free (context);

}

/* Don't forget to initialize this variables and free the memory after the
   call to parse_file () */

/* char *text;
   gsize length;
   GMarkupParseContext *context =  g_markup_parse_context_new (&parser, 0,
   &level, NULL);
   g_markup_parse_context_free (context); */
