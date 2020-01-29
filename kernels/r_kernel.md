JupyterHub R Kernel
===

## Install

* AWS SM Session Manager on to the EMR master
* `sudo docker exec -it jupyterhub bash`
* `conda create -y -n rkernel`
* `source activate rkernel`
* `conda install -y -c r r-irkernel r-essentials r-igraph r-sparklyr r-dplyr`
* `mkdir -p /usr/local/share/jupyter/kernels/rkernel/`
* `echo 'contents of kernel.json>' > /usr/local/share/jupyter/kernels/rkernel/kernel.json`

## Additional packages

Packages can be searched for online: https://anaconda.org/

 * SSH on to EMR master
 * `sudo docker exec -it jupyterhub bash`
 * `source activate rkernel`
 * `conda install -c r <package name>`
