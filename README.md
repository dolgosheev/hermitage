# Hermitage #

docker build

```text
docker build . -f Hermitage.dockerfile  -t hermitage-server:v1
```

docker run

```text
docker run -d -p 8080:80 hermitage-server:v1
```


# Link preparer #

## Instruction ##

First arg - link (ex. http://localhost:8023), second image name (ex. image.jpg)

---

as result - string for upload

exanple

```text
curl -XPOST http://localhost:8080 --data-binary @pesda.jpg -H "Content-Type: image/jpeg" -H "X-Authenticate-Timestamp: 1668019799" -H "X-Authenticate-Signature: d2a3836b6b7d3bf038330276c142bf335987dcb4aa84ef49efa343baced8054e"
```
