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
  update  update taxonomy
  
Example:
  hugh add '{"categories" : "video"}' '{"tags" : "video"}'
  hugh del '{"categories" : "video"}' '{"categories" : "video"}'
  hugh update '{"authors" : ""}' '{"authors" : "persons"}'
  
Requirments:
  luafilesystem, rxi-json
~~~

## Notes
1. Arguments `filter` and `update` must be valid JSON. Use double quotes for keys and values, and single - for entire JSON string.
2. Empty values in `filter` used as wildcard (any value), empty values in `update` ignored.

