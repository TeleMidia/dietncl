local syntax = {
   ncl = {
      parent = nil,
      required_attrs = {'id'},
      optional_attrs = {'title', 'xmlns'},
      children = {'head?', 'body?'}
   },
   head = {
      parent = {'ncl'},
      required_attrs = nil,
      optional_attrs = nil,
      children = {'importedDocumentBase?', 'ruleBase?', 'transitionBase?',
                  'regionBase*', 'descriptorBase?', 'connectorBase?',
                  'meta*', 'metadata*'}
   },
   body = {
      parent = {'ncl'},
      required_attrs = nil,
      optional_attrs = {'id'},
      children = {'port*', 'property*', 'media*', 'context*', 'switch*',
                  'link*', 'meta*', 'metadata*'}
   }
}

print (syntax.head.parent[1])

local arg = 'ncl'
local list = syntax[arg].required_attrs

for i=1, #list do
   print ('>>>>>>', list[i])
end
