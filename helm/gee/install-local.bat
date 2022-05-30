set environment=local-win
set namespace=gee
helm install gee . -f ./values.yaml -f ./evnironments/%environment%.yaml -n %namespace% --create-namespace
