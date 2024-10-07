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
  luafilesystem
  lunajson
  rxi-json (@todo)
~~~

## Замечания

1. Параметры `filter` и `update` должны быть корректными JSON. При передаче в командной строке используйте двойные кавычки для узлов и значений, а одиночные - для всей JSON-строки.
2. Пустые значения в `filter` соответствуют записям, в которых есть ключ - с любым содержанием.
