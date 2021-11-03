echo -n 'admin' > ./username.txt
echo -n '1f2d1e2e67df' > ./password.txt

kubectl create secret generic db-user-pass --from-file=./username.txt --from-file=./password.txt

kubectl get secret db-user-pass -o jsonpath='{.data}'

echo 'MWYyZDFlMmU2N2Rm' | base64 --decode