#!/bin/bash

cat > ca.pem <<EOF
-----BEGIN CERTIFICATE-----
MIIDozCCAougAwIBAgIUQLr6DBTh0/jvDpz36OtUvajc7OgwDQYJKoZIhvcNAQEL
BQAwaDELMAkGA1UEBhMCVVMxDzANBgNVBAgTBk9yZWdvbjERMA8GA1UEBxMIUG9y
dGxhbmQxEzARBgNVBAoTCkt1YmVybmV0ZXMxCzAJBgNVBAsTAkNBMRMwEQYDVQQD
EwpLdWJlcm5ldGVzMB4XDTE4MDIwMjE2MzUwMFoXDTIzMDIwMTE2MzUwMFowaDEL
MAkGA1UEBhMCVVMxDzANBgNVBAgTBk9yZWdvbjERMA8GA1UEBxMIUG9ydGxhbmQx
EzARBgNVBAoTCkt1YmVybmV0ZXMxCzAJBgNVBAsTAkNBMRMwEQYDVQQDEwpLdWJl
cm5ldGVzMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsmG3VR4NHKUE
nZDGy6GtO5v6ec47mJ5HjvadVt7kXfMceE1xmBNxRLgm1wiEw/+i6hw9Emim8lrJ
vILah1kmLNf53vW5x01rwNwAbax/H/8eEzWG3AYjAMdBJQ1/ONhVTo82TZ3UFjCC
95tpuhjq4DoEB2tIloBoeBsMoe+jWsRP5gnFWP4Bxlh2/TwcGJUMmAYtxaTPBHHw
Ez2b5pQPZFpim7g495CvMEZBMPzNnSKy9RM3nOdg2aB/iZvYLt5VDtQsRa1/ApZR
NmMrL6lJe+fwMBmCJjsuf5ph5Q5gBNCy7D0ozm26s2w24SdPuZR4OJ6D5eHzYuNn
3JTnPxdP6QIDAQABo0UwQzAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB
/wIBAjAdBgNVHQ4EFgQU+0SvZy/wCOXx0M0Lk4KeuB7rGhEwDQYJKoZIhvcNAQEL
BQADggEBAJxv7XdvytG5g8WGYw5cS1mi5uPtjD0KxqPHh97RE/eRx8A01MD3mUkN
wI/XIW/I7liOWbLWmTpkacvuaGu1QS+ou9PPBrEIhKDiY2FW6d15Fi0oYx4mU1Xl
qGbuapVAzFLVkGqTIKjlBYx6yJI/4OUctMd+S3eagT8Pysa+Z1YCYvf1FVA+m6N1
fv77dSTQxvf8recBBpRYDir6sgTwPWTcgBeslbLUqy7vC0jOw1ymYP6uAa+9i/Nw
QuL5CN+o33UBxX8AVOiulLPr46acHOmE0uqbZvvM/eD3gqBx7WrQ9vji6L61C9h7
klBqhDYjVAACCeeE4uHlQAU/RwuXInA=
-----END CERTIFICATE-----
EOF
cat > ca-key.pem <<EOF
-----BEGIN RSA PRIVATE KEY-----
MIIEpQIBAAKCAQEAsmG3VR4NHKUEnZDGy6GtO5v6ec47mJ5HjvadVt7kXfMceE1x
mBNxRLgm1wiEw/+i6hw9Emim8lrJvILah1kmLNf53vW5x01rwNwAbax/H/8eEzWG
3AYjAMdBJQ1/ONhVTo82TZ3UFjCC95tpuhjq4DoEB2tIloBoeBsMoe+jWsRP5gnF
WP4Bxlh2/TwcGJUMmAYtxaTPBHHwEz2b5pQPZFpim7g495CvMEZBMPzNnSKy9RM3
nOdg2aB/iZvYLt5VDtQsRa1/ApZRNmMrL6lJe+fwMBmCJjsuf5ph5Q5gBNCy7D0o
zm26s2w24SdPuZR4OJ6D5eHzYuNn3JTnPxdP6QIDAQABAoIBAQCxoWa7xuINrTGs
adfcPRJRcqB5HOnxr2PYtDG3qNtFxuqJzayZYHsBkFN0/BGhT3X+pMIYC8h7O/b5
1mAgOaEvNJ6o7I7kLW9orGtsy0IILbbYMAwsG5xNkR2I9SjEBYDlau0LW2gv9Hzm
bodY/qkdQghzDt1IqXPebiklNIm5vmmNjBJtcYtJFRwR3Q0qAETLDaBSS4FtUplc
1w4Cq1Iu8rTUcdGOSq89doijCWV5HaXRLuWtvnitTRoz2kFWKpLP9sjC1G4ydRTv
Kh5sJH0LpFaPwQdsPy7R6MUQa+1L847r1qL0V0V0hArVTTHdxkE5T02IJoQP86TB
XYCQaSARAoGBAOwhAWIT9xWfg5CJx8Uix9XjKt9EwbV0PlXO9cDapAAvXS2TDu8v
cMKqnFa5cnpZEUVdKsM5FBfNsjqzCMxaBxvH1YzKN8gIqp0WGgLjTgyGGPxft9nG
m7IsgIfgwLsT9g6uImR1EyknxUrSP9XdH4eFDy01Y52sLS/8OcgnhwCFAoGBAMFk
pTjE20SHI/Y6bfYUrfNUKAKGWSOkMw7/PES/wuXXSKhOVnzV229rIKLmFwvr6pz2
9tn+VBsBs4A0ZF6AOWrHojZ9Dz3e8HDSvc4EHLidgre3u5bNeOHKAP1WDXhJAXsX
gL4Zqez/GnHOO/p3o4S9BPk2oGARXeVKogdVIMEVAoGBAMpUTbcYnHOuxzEmnkLR
VqJzkNzXMZSmEnO8bt/deQGflBvlErroz5o+TtAQ/4LOpvnkpyu40PrEip+5oSRZ
UBYB2X5WGA4TPv5zXb5zvwEENoyqCANXJzo437mOYBbtN73EgDvMBasSJP/DwGck
nkulPCfkw4LrcZzYZzqWhBtxAoGBAJ2lXGW1WwQ2oWMDaEWzv8Td8it0ts8t940f
FFL6enZ/krPX//qNHe5qRlVj+J94NWy0iK9U+dx1+4vjqXm7TpKzn5CJS1ZlGFzv
/Vcl1P/NLhRyypD4d7SexUW90wcdg/6CPyk3pGQT48unkQ7wXbRDnP1FwV/uaDsU
JpaRlzytAoGAK8GhDSwA8W/YByDGfSh0ZJF+WBMxn9iyLlbFTxPTOG+cqO9+QpYs
7gQJdRWlnm3zllU4Z0C2YG6oZAGwf+H0bZRID8K7ffMuWllfordZ1MpKO6cZUSE7
XBryWL3jAJupy7fqImqzcRnPji5RXTG65qzACLBHhPypq+tTTQlcfR0=
-----END RSA PRIVATE KEY-----
EOF
cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF
cat > admin-csr.json <<EOF
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "O": "system:masters"
    }
  ]
}
EOF
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin

exit 0