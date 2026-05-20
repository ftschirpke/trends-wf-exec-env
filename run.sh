#!/usr/bin/env bash

function error () {
    echo "Error: $1"
    exit 1
}

cd $(dirname $0)

dir=""

if [[ $# -lt 1 ]]; then
     error "Not enough arguments"
fi

dir="$1"
configfile="$dir/config.sh"
podfile="$dir/pod.yaml"
local_wfpath="/home/friedrich/shk-leser/FONDA_trends-nf-revisited"
local_wfname="$(basename $local_wfpath)"
wfname="wf"

source $configfile
# config file MUST contain:
# podname: the name of the management pod
# workdir: the path to the working directory
# datadir: the path to the data
# label_key: the key of the label used to select nodes
# label_val: the value of the label used to select nodes

wfpath="$workdir/$wfname"

kubectl get pods | grep -q "$podname"
pod_exists=$?

if [[ $pod_exists -ne 0 ]]; then
    kubectl create -f $podfile
    echo
    kubectl get pods -o wide
    echo
fi

kubectl wait --for=condition=Ready pod/$podname --timeout=120s
echo

kubectl get nodes -L $label_key | grep -e "NAME" -e "$label_val"
echo
kubectl get pods -o wide
echo

kubectl exec $podname -- /bin/bash -c "rm -rdf $workdir/$local_wfname $wfpath"
kubectl cp "$local_wfpath" $podname:$workdir
kubectl exec $podname -- /bin/bash -c "mv $workdir/$local_wfname $wfpath"
kubectl cp "$dir/command.sh" $podname:$workdir/nf-work

kubectl exec -it $podname -- /bin/bash
