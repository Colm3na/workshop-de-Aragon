# Exercice: Customize/fix the following script and buidl the Aragon Cooperative
# scheme described in:
# https://forum.aragon.org/t/community-initiative-aragon-cooperative/356
# Documentation: https://hack.aragon.org/docs/guides-custom-deploy

sudo npm install -g @aragon/cli --unsafe-perm=true
aragon ipfs
E="--environment aragon:rinkeby"
dao new $E
DAO=<dao-address>
xdg-open http://rinkeby.aragon.org/#/$DAO

# Token Manager
dao token new "Member" "MBR" 0 0 $E
TOKEN=<token-address>
dao install $DAO token-manager --app-init none $E
dao apps $DAO --all $E
TM=<token-manager-address>
dao token change-controller $TOKEN $TM $E
ME=0xb4124cEB3451635DAcedd11767f004d8a28c6eE7
dao acl create $DAO $TM MINT_ROLE $ME $ME $E
dao exec $DAO $TM initialize $TOKEN false 1 $E

# Voting
dao install $DAO voting --app-init-args $TOKEN 600000000000000000 250000000000000000 604800 $E
dao apps $DAO --all $E
VOTING=<voting-address>
dao acl create $DAO $VOTING CREATE_VOTES_ROLE $TM $VOTING $E
dao acl create $DAO $VOTING VOTE_ROLE $TM $VOTING $E

# Vault
dao install $DAO vault $E
dao apps $DAO --all $E
VAULT=<vault-address>

# Finance
dao install $DAO finance --app-init-args $VAULT 2592000 $E
dao apps $DAO --all $E
FINANCE=<finance-address>
dao acl create $DAO $VAULT TRANSFER_ROLE $FINANCE $VOTING $E
dao acl create $DAO $FINANCE CREATE_PAYMENTS_ROLE $VOTING $VOTING $E
dao acl create $DAO $FINANCE EXECUTE_PAYMENTS_ROLE $VOTING $VOTING $E
dao acl create $DAO $FINANCE MANAGE_PAYMENTS_ROLE $VOTING $VOTING $E

# Token Manager #2
dao token new "MembershipCommitee" "MC" 0 0 $E
TOKEN2=<token2-address>
dao install $DAO token-manager --app-init none $E
dao apps $DAO --all $E
TM2=<token-manager-2-address>
dao token change-controller $TOKEN2 $TM2 $E
dao acl create $DAO $TM2 MINT_ROLE $VOTING $VOTING $E
dao exec $DAO $TM2 initialize $TOKEN2 false 1 $E

# Voting #2
dao install $DAO voting --app-init-args $TOKEN2 500000000000000000 250000000000000000 604800 $E
dao apps $DAO --all $E
VOTING2=<voting-address>
dao acl create $DAO $VOTING2 CREATE_VOTES_ROLE $TM2 $VOTING $E
dao acl create $DAO $VOTING2 VOTE_ROLE $TM2 $VOTING $E

# Clean up
dao acl $DAO $E
dao acl grant $DAO $TM MINT_ROLE $VOTING2 $E 
dao acl revoke $DAO $TM MINT_ROLE $ME $E
dao acl set-manager $DAO $TM MINT_ROLE $VOTING $E