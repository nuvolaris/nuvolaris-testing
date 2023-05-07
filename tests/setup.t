Start
  $ export EXTRA=D=1
  $ nuv setup status
  nothing installed yet
Docker
  $ nuv setup devcluster
  nuv setup docker create
  nuv setup kubernetes create
  nuv setup nuvolaris login
  $ nuv setup status
  nuv setup devcluster status
  $ nuv setup devcluster --status
  nuv setup docker status
  $ nuv setup devcluster --uninstall
  nuv setup docker delete
  $ nuv setup status
  nothing installed yet
