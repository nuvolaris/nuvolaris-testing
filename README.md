# Setting up the nuvolaris-testing environment

Since we are testing in many clouds and environments, test setup is pretty compilcated. Details are in [this document](SETUP.md), please read it carefully...

# Nuvolaris 3.0.0 "Morpheus" Testing
<img height="180" src="img/morpheus.png">

Welcome to the Nuvolaris "Morpheus" release challenge! 

The goal of the challenge is to pass all the tests in the grid, using GitHub Actions.

## Acceptance Test Status: 103/103
<img src="img/progress.svg" width="60%">

|  |               |Kind|M8S |K3S |EKS |AKS |GKE |OSH |
|--|---------------|----|----|----|----|----|----|----|
|1 |Deploy         | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | 
|2 |SSL            | N/A| ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
|3 |Sys Redis      | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
|4a|Sys FerretDB   | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | 
|4b|Sys Postgres   | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | 
|5 |Sys Minio      | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | 
|6 |Login          | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | 
|7 |Statics        | N/A| ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | 
|8 |User Redis     | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | 
|9a|User FerretDB  | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
|9b|User Postgres  | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | 
|10|User Minio     | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | 
|11|Nuv Win        | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
|12|Nuv Mac        | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
|13|We skip this one | N/A | N/A | N/A | N/A | N/A | N/A | N/A |
|14|Runtimes       | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

## The challengers

### Franztt

![](img/franztt.jpeg)

### Giusdp

![](img/giusdp.png)

### Msciab
![](img/msciab.jpg)


