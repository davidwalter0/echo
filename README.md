**echo a simple http echo service**

*Get*

```
go get github.com/davidwalter0/echo
```

*Docker Container*

```
make
make image
```

*Kubernetes Echo Deployment*

Assumes that a configuration 

```
make apply
```

Note: 

Assumptions:

- The .version file is updated to provide the semantic version for the release
- The kubernetes configuration wants a configuration and kubectl and
  the kubernetes commands use the local definition of a kubectl
  command accessed with $(kubectl) and args ...

```
export kubectl=${GOPATH}/bin/kubectl  --kubeconfig=${PWD}/cluster/auth/kubeconfig
```

---
*sample output*

```
--------------------------------
2017-12-31T15:37:04-05:00
--------------------------------
Server Host IP 192.168.0.26
GET / HTTP/1.1
Host: localhost:8888
Accept: */*
User-Agent: curl/7.55.1


127.0.0.1:46012
/

```
