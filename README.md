SG-ItemViewer is a in game item/prop viewer.

usage :
`/show3ditem prop_name`

controls :
`W / S - Adjust Height`
`ARROW KEYS - Adjust Posistion`
`Mouse Click Down + Drag - Adjust Rotation`
`ESCAPE / BACKSPACE - Cose NUI`

export :
`exports['SG-ItemViewer']:startViewingModel('model_name')`

example command :
```
RegisterCommand('example_command', function(source, args)
   -- uses arg from command -> /hello_world prop_tool_blowtorch
    exports['SG-ItemViewer']:startViewingModel(args[1])
    print(args[1])
end, false)
```

https://forum.cfx.re/u/okcrp/
