environment=local-linux
namespace=gee
helm install gee . -f ./values.yaml -f ./evnironments/$(environment).yaml -n $namespace --create-namespace
