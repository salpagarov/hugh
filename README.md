# Hugh v0.1

~~~
Usage:
  hugh [<command> ['<filter-json>' ['<update-json>']]]
  
Commands:
  help    this text
  core    get taxonomies
  list    get posts list
  add     enrich metadata
  del     enlean metadata
  
Example:
  hugh add '{"categories" : "video"}' '{"tags" : "video"}'
  hugh del '{"categories" : "video"}' '{"categories" : "video"}'
  
Requirments:
  luafilesystem
  lunajson      
~~~

