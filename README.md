# hugh v0.1

~~~
Usage:
  hugh [<command> ['<filter-json>' ['<update-json>']]]
  
Commands:
  help    this text
  core    get taxonomies
  list    get posts list
  add     enrich metadata
  del     enlean metadata
  ren     rename taxons
  
Example:
  hugh add '{"categories" : "video"}' '{"tags" : "video"}'
  hugh del '{"categories" : "video"}' '{"categories" : "video"}'
  hugh ren '{"authors" : ""}' '{"authors" : "persons"}'
  
Requirments:
  luafilesystem, rxi-json
~~~

## Notes

1. `filter` and `update` parameters must be valid JSON. Use double quotes for keys and values, and single - for entire JSON string.
1. Empty values in `filter` correspond to records whose metadata contains a key with any value
1. Empty values in `update` ignored.
2. With `ren` command values in `update` defines new key names.

