# To add new collaborators

Find your public gpg key with:

```
$ gpg --list-keys --keyid-format LONG
```

​	You should get something like this:

```
pub   rsa4096/920B3F64DC2C699A 2016-10-12 [SC] [expires: 2020-10-12]
         2B18220F27F54EF4DEE1D0BB78FCB7A47D7827E5
uid   [ultimate] Mickey Mouse <foo@bar.com>
sub   rsa4096/FAB129D811D21E5B 2016-10-12 [E] [expires: 2020-10-12]
```

If you don't have a key already, please read this GitHub page describing how to generate one.

​    https://help.github.com/en/articles/generating-a-new-gpg-key

You need to get the public key which is a hexadecimal string. In this case it is 

```
2B18220F27F54EF4DEE1D0BB78FCB7A47D7827E5
```


The next step is to export the key to a file like this:

```
$ gpg --armor --export --output Path/to/Save/location/key.gpg 2B18220F27F54EF4DEE1D0BB78FCB7A47D7827E5
```

*DO NOT SAVE THE KEY FILE IN THE REPOSITORY!*

Give this file to any user who already have the authority to add users to git-crypt.
The person with authority should import the key.

    $ gpg --import Path/to/key.gpg

This will add the key to their keyring.  The next step is to trust the key.

    $ gpg --edit-key 2B18220F27F54EF4DEE1D0BB78FCB7A47D7827E5

This will lead to a gpg prompt where you can get the fingerprint of the key by using fpr command

    gpg> fpr

Add trust level to user by trust command. It will ask for a trust level to select, add accordingly.

    gpg> trust

After verifying the fingerprint save changes by save command

    gpg> save

Quit the prompt by quit command

    gpg> quit

Add user to the git-crypt repo

    git-crypt add-gpg-user 2B18220F27F54EF4DEE1D0BB78FCB7A47D7827E5

Push the changes to master in GitHub. The user requiring access to secrets can then pull down the repo.

The final step should be to unlock the secrets using:

    git-crypt unlock

The encrypted secrets.yaml file should now be user readable.