# Demo Initialize: Initialize Demo Account Dependencies (via AWSCLI)

This document describes the manual procedure to initialize additional dependencies within the demo
account, using the AWSCLI whenever possible.

### Prerequisites

This variant must be run by root on the Eucalyptus CLC host.

It assumes the environment was installed via FastStart and the additional scripts needed to
initialize DNS, PKI, SSL reverse-proxy and the initialization of Euca2ools and AWSCLI, as
described in the [FastStart Install](../../../installs/install-10-faststart) section, have
been run, or equivalent manual configuration has been done.

It also assumes the [demo-00-initialize.md](./demo-00-initialize.md),
[demo-01-initialize-account.md](./demo-01-initialize-account.md) and
[demo-02-initialize-account-administrator.md](./demo-02-initialize-account-administrator.md)
procedures have been run.

### Define Parameters

The procedure steps in this document are meant to be static - pasted unchanged into the appropriate
ssh session of each host. To support reuse of this procedure on different environments with
different identifiers, hosts and IP addresses, as well as to clearly indicate the purpose of each
parameter used in various statements, we will define a set of environment variables here, which
will be pasted into each ssh session, and which can then adjust the behavior of statements.

1. Define Environment Variables used in upcoming code blocks

    Adjust the variables in this section to your environment.

    ```bash
    export REGION=hp-gol01-d6
    export ACCOUNT=demo
    export USER=admin

    export PROFILE=$REGION-$ACCOUNT-$USER
    ```

This script also assumes you have additionally configured AWSCLI tools with appropriate region entries.

### Initialize Demo Account Dependencies

The steps below are automated in the [demo-03-initialize-account-dependencies-awscli.sh](../bin/demo-03-initialize-account-dependencies-awscli.sh) script.

2. List Images available to Demo (demo) Account Administrator

    ```bash
    aws ec2 describe-images --profile $PROFILE --region $REGION --output text
    ```

3. Configure Demo Keypair

    ```bash
    cat << EOF > ~/.ssh/demo_id_rsa
    -----BEGIN RSA PRIVATE KEY-----
    MIIEpAIBAAKCAQEAmxRVKSZsQEsxlrOZiFfyZy2oKexnf0V7Juq7wfVEaEv6J47/
    tfjGELCOmf5rIY2OfeMumBf5lzoPNjHDZY1pYbdixeLoIaQOYuedIoXkq0yzPV/K
    kYrNTkZ6fkZrQ+9PpLjsfyD8anBNU9gs1qDqCM5nAZhtO7L7XFeQGOb3QGOLOsz1
    1G5qulgCFInA7CpPb1qg6x5QMDaEmAuBy4KY50HNP3JbIRNYSJg4yXeqGULCB6S0
    Aaz81TDeck1kTCnvm/7ZBsiecANPtQp2z4TgS/ngBpTff76f0/okPY4B77NVnKhe
    D0UyS2lHdw8vsr/Qbt+71mTQp4JicLyonylHGwIDAQABAoIBAQCUxyr0cZJFFF6c
    r+1J6uX5qsm8frrEVUpTCbvb1owsa0exD/WvBN4wQNJuVrE83Wuoxn17GPUw6liR
    q6hEEyjYwHEYXBpLu/K5XG9aIY5B8TG8XdwfSUSyJdd6seBSqpKD+42YYXMIQnlN
    SQWrW3FrxWj5FN0m+w0/iBoMafknYVo6xn6SVC0VUGuQFuCEJhTpxBC2pCgnaVqM
    baivYG2TG9/e+1TR7HzRnjvKFQ4md5nRkhVuXjbcJqarWF3L/CErgKqgqKMwrn6s
    HIu24tjBAM8JVYjKkmx3hyiBUUm6rF2KcG3wzVON5tMDBxWQjDdcucsRdTph6Eh3
    IQ0bpbPxAoGBAM3pvGzfSE+cIyzgVHP3Vz42a8HjWC7JjMoWL4YibtvDwXF7Kxt6
    /rPceihZRyMwmpA6NFNRu85BGaT1NmGEaiXjYST9TqwIKliH/3IDNoZJA8d76zLD
    UjD2ufubpvsDuEm8rt0lroFH0x3XekgNe1OEh8/9JZqMLZG2qYf++1mPAoGBAMDN
    LFjPrbnySJni40EzkOHxdKOGTPBnnBB12vPUn27JOB2StJCQNeu5cRAWOCHBSx+6
    Uag9h9Xpvl64PQbyvOBJo+RBjc0BomyuTeqafcu3d4IxHffhtv0WMJzy793KUORR
    278bEfRnGIZFHAo/celW1vUHdXI5Ufz0kd5LwTu1AoGBAJrJlrQ80I3PsH1+kN2v
    0+xXWn+gl9xr9CLBtK3fWnhnWhYlYY1B0w9/sHB+VER2t+mtZ0Iu0b/FHjLrhhqe
    QHEE0TTOGgKmDLcKXJLnKWieoHGnjHFXdISMI9io9EgDTthXNxfUyK40QNZQ8YIS
    aF+q47EM+eSIdYTwy9YIbgevAoGAV6rzx05nyG2K5a5td3BjKNoKF3Ex+v6h0DpG
    3SiJdm64vXm/8Rwh6JXh+1afH3otFrg5+S5BXdtzXM6ZsVce2z2g8GF+gQGFQbXg
    aBTnroI2LVT4M4bHFj3IzRUKTOd58Nfn+/XrLB7U3/j8zwwaV+fMxo4lsVKvHT54
    NYRs0SECgYAoBT9LNHEzsKtA+kAz2PDlg7b0u/3Zx1XWn39TkSmWm1YlKhOw+rZV
    ysocsRRkDaWdjv5gmcUbupnSgh/tWyJSaBfNGROYDCsHx4V8LRsc48bTCyhaxLMI
    MXhYdU42xdkDydmJPDBc0Q6VInxqkiqHTZ/c+gBoiLCIdb3FRvJwyQ==
    -----END RSA PRIVATE KEY-----
    EOF

    chmod 0600 ~/.ssh/demo_id_rsa

    cat << EOF > ~/.ssh/demo_id_rsa.pub
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCbFFUpJmxASzGWs5mIV/JnLagp\
    7Gd/RXsm6rvB9URoS/onjv+1+MYQsI6Z/mshjY594y6YF/mXOg82McNljWlht2LF\
    4ughpA5i550iheSrTLM9X8qRis1ORnp+RmtD70+kuOx/IPxqcE1T2CzWoOoIzmcB\
    mG07svtcV5AY5vdAY4s6zPXUbmq6WAIUicDsKk9vWqDrHlAwNoSYC4HLgpjnQc0/\
    clshE1hImDjJd6oZQsIHpLQBrPzVMN5yTWRMKe+b/tkGyJ5wA0+1CnbPhOBL+eAG\
    lN9/vp/T+iQ9jgHvs1WcqF4PRTJLaUd3Dy+yv9Bu37vWZNCngmJwvKifKUcb\
     demo@hpcloud.com
    EOF
    ```

4. Import Demo (demo) Account Administrator Demo Keypair

    ```bash
    aws ec2 import-key-pair --key-name=demo \
                            --public-key-material file://~/.ssh/demo_id_rsa.pub \
                            --profile $PROFILE --region $REGION --output text
    ```

5. Create Demo (demo) Account Demo (demo-demo) Bucket

    ```bash
    aws s3 mb s3://demo-demo --profile $PROFILE --region $REGION --output text
    ```

6. Create Demo (demo) Account Demos (Demos) Role and associated InstanceProfile

    This Role is intended for Demos which need Administrator access to Resources.

    ```bash
    cat << EOF > /var/tmp/demo/DemosRoleTrustPolicy.json
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": { "Service": "ec2.amazonaws.com"},
          "Action": "sts:AssumeRole"
        }
      ]
    }
    EOF

    aws iam create-role --role-name Demos \
                        --assume-role-policy-document file:///var/tmp/demo/DemosRoleTrustPolicy.json \
                        --profile $PROFILE --region $REGION --output text

    aws iam create-instance-profile --instance-profile-name Demos \
                                    --profile $PROFILE --region $REGION --output text

    aws iam add-role-to-instance-profile --instance-profile-name Demos --role-name Demos \
                                         --profile $PROFILE --region $REGION --output text
    ```

7. Create Demo (demo) Account Demos (Demos) Role Policy

    This Policy provides full access to all resources, except users and groups.

    ```bash
    cat << EOF >> /var/tmp/demo/DemosRolePolicy.json
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": [
            "cloudformation:DescribeStacks",
            "cloudformation:DescribeStackEvents",
            "cloudformation:DescribeStackResource",
            "cloudformation:DescribeStackResources",
            "cloudformation:GetTemplate",
            "cloudformation:List*",
            "ec2:Describe*",
            "s3:Get*",
            "s3:List*"
          ],
          "Effect": "Allow",
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": "s3:ListAllMyBuckets",
          "Resource": "arn:aws:s3:::*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "s3:ListBucket",
            "s3:GetBucketLocation"
          ],
          "Resource": "arn:aws:s3:::demo-demo"
        },
        {
          "Effect": "Allow",
          "Action": [
            "s3:PutObject",
            "s3:GetObject",
            "s3:DeleteObject",
            "s3:PutObjectAcl",
            "s3:PutObjectVersionAcl"
          ],
          "Resource": "arn:aws:s3:::demo-demo/*"
        }
      ]
    }
    EOF

    aws iam put-role-policy --role-name Demos --policy-name DemosPolicy \
                            --policy-document file:///var/tmp/demo/DemosRolePolicy.json \
                            --profile $PROFILE --region $REGION --output text
    ```

8. Create Demo (demo) Account Demos (Demos) Group

    This Group is intended for Demos which have Administrator access to Resources.

    ```bash
    aws iam create-group --group-name Demos \
                         --profile $PROFILE --region $REGION --output text
    ```

9. Create Demo (demo) Account Demos (Demos) Group Policy

    This Policy provides full access to all resources, except users and groups.

    ```bash
    mkdir -p /var/tmp/demo

    cat << EOF >> /var/tmp/demo/DemosGroupPolicy.json
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "NotAction": "iam:*",
          "Resource": "*",
          "Effect": "Allow"
        }
      ]
    }
    EOF

    aws iam put-group-policy --group-name Demos --policy-name DemosPolicy \
                             --policy-document file:///var/tmp/demo/DemosGroupPolicy.json \
                             --profile $PROFILE --region $REGION --output text
    ```

10. Create Demo (demo) Account Developers (Developers) Group

    This Group is intended for Developers who can modify Resources.

    ```bash
    aws iam create-group --group-name Developers \
                         --profile $PROFILE --region $REGION --output text
    ```

11. Create Demo (demo) Account Developers (Developers) Group Policy

    This Policy provides full access to all resources, except users and groups.

    ```bash
    cat << EOF >> /var/tmp/demo/DevelopersGroupPolicy.json
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "NotAction": "iam:*",
          "Resource": "*",
          "Effect": "Allow"
        }
      ]
    }
    EOF

    aws iam put-group-policy --group-name Developers --policy-name DevelopersPolicy \
                             --policy-document file:///var/tmp/demo/DevelopersGroupPolicy.json \
                             --profile $PROFILE --region $REGION --output text
    ```

12. Create Demo (demo) Account Users (Users) Group

    This Group is intended for Users who can view but not modify Resources.

    ```bash
    aws iam create-group --group-name Users \
                         --profile $PROFILE --region $REGION --output text
    ```

13. Create Demo (demo) Account Users (Users) Group Policy

    This Policy provides ReadOnly access to all resources.

    ```bash
    cat << EOF >> /var/tmp/demo/UsersGroupPolicy.json
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": [
            "autoscaling:Describe*",
            "cloudformation:DescribeStackEvents",
            "cloudformation:DescribeStackResource",
            "cloudformation:DescribeStackResources",
            "cloudformation:DescribeStacks",
            "cloudformation:GetTemplate",
            "cloudformation:List*",
            "cloudwatch:Describe*",
            "cloudwatch:Get*",
            "cloudwatch:List*",
            "ec2:Describe*",
            "ec2:GetConsoleOutput",
            "elasticloadbalancing:Describe*",
            "iam:GenerateCredentialReport",
            "iam:Get*",
            "iam:List*",
            "s3:Get*",
            "s3:List*",
            "swf:Count*",
            "swf:Describe*",
            "swf:Get*",
            "swf:List*",
            "tag:Get*"
          ],
          "Effect": "Allow",
          "Resource": "*"
        }
      ]
    }
    EOF

    aws iam put-group-policy --group-name Users --policy-name UsersPolicy \
                             --policy-document file:///var/tmp/demo/UsersGroupPolicy.json \
                             --profile $PROFILE --region $REGION --output text
    ```

14. Create Demo (demo) Account Demo (demo) User

    ```bash
    aws iam create-user --user-name demo \
                        --profile $PROFILE --region $REGION --output text
    ```

15. Add Demo (demo) Account Demo (demo) User to Demos (Demos) Group

    ```bash
    aws iam add-user-to-group --group-name Demos --user-name demo \
                              --profile $PROFILE --region $REGION --output text
    ```

16. Create Demo (demo) Account Demo (demo) User Login Profile

    This allows the Demo Account Demo User to login to the console.

    ```bash
    aws iam create-login-profile --user-name demo --password demo123-demo \
                                 --profile $PROFILE --region $REGION --output text
    ```

17. Create Demo (demo) Account Demo (demo) User Access Key

    This allows the Demo Account Demo User to run API commands.

    ```bash
    mkdir -p ~/.creds/$REGION/demo/demo

    result=$(aws iam create-access-key --user-name demo \
                                       --query 'AccessKey.{AccessKeyId:AccessKeyId,SecretAccessKey:SecretAccessKey}' \
                                       --profile $PROFILE --region $REGION --output text)
    read access_key secret_key <<< $result

    cat << EOF > ~/.creds/$REGION/demo/demo/iamrc
    AWSAccessKeyId=$access_key
    AWSSecretKey=$secret_key
    EOF
    ```

18. Create Demo (demo) Account Demo (demo) User Euca2ools Profile

    This allows the Demo Account Demo User to run API commands via Euca2ools.

    ```bash
    cat << EOF >> ~/.euca/$REGION.ini
    [user $REGION-demo-demo]
    key-id = $access_key
    secret-key = $secret_key

    EOF

    euca-describe-availability-zones --region $REGION-demo-demo@$REGION
    ```

19. Create Demo (demo) Account Demo (demo) User AWSCLI Profile

    This allows the Demo Account Demo User to run AWSCLI commands.

    ```bash
    cat << EOF >> ~/.aws/config
    [profile $REGION-demo-demo]
    region = $REGION
    output = text

    EOF

    cat << EOF >> ~/.aws/credentials
    [$REGION-demo-demo]
    aws_access_key_id = $access_key
    aws_secret_access_key = $secret_key

    EOF

    aws ec2 describe-availability-zones --profile $REGION-demo-demo --region $REGION --output text
    ```

20. Create Demo (demo) Account Developer (developer) User

    ```bash
    aws iam create-user --user-name developer \
                        --profile $PROFILE --region $REGION --output text
    ```

21. Add Demo (demo) Account Developer (developer) User to Developers (Developers) Group

    ```bash
    aws iam add-user-to-group --group-name Developers --user-name developer \
                              --profile $PROFILE --region $REGION --output text
    ```

22. Create Demo (demo) Account Developer (developer) User Login Profile

    This allows the Demo Account Developer User to login to the console.

    ```bash
    aws iam create-login-profile --user-name developer --password demo123-developer \
                                 --profile $PROFILE --region $REGION --output text
    ```

23. Create Demo (demo) Account Developer (developer) User Access Key

    This allows the Demo Account Developer User to run API commands.

    ```bash
    mkdir -p ~/.creds/$REGION/demo/developer

    result=$(aws iam create-access-key --user-name developer \
                                       --query 'AccessKey.{AccessKeyId:AccessKeyId,SecretAccessKey:SecretAccessKey}' \
                                       --profile $PROFILE --region $REGION --output text)
    read access_key secret_key <<< $result

    cat << EOF > ~/.creds/$REGION/demo/developer/iamrc
    AWSAccessKeyId=$access_key
    AWSSecretKey=$secret_key
    EOF
    ```

24. Create Demo (demo) Account Developer (developer) User Euca2ools Profile

    This allows the Demo Account Developer User to run API commands via Euca2ools.

    ```bash
    cat << EOF >> ~/.euca/$REGION.ini
    [user $REGION-demo-developer]
    key-id = $access_key
    secret-key = $secret_key

    EOF

    euca-describe-availability-zones --region $REGION-demo-developer@$REGION
    ```

25. Create Demo (demo) Account Developer (developer) User AWSCLI Profile

    This allows the Demo Account Developer User to run AWSCLI commands.

    ```bash
    cat << EOF >> ~/.aws/config
    [profile $REGION-demo-developer]
    region = $REGION
    output = text

    EOF

    cat << EOF >> ~/.aws/credentials
    [$REGION-demo-developer]
    aws_access_key_id = $access_key
    aws_secret_access_key = $secret_key

    EOF

    aws ec2 describe-availability-zones --profile $REGION-demo-developer --region $REGION --output text
    ```

26. Create Demo (demo) Account User (user) User

    ```bash
    aws iam create-user --user-name user \
                        --profile $PROFILE --region $REGION --output text
    ```

27. Add Demo (demo) Account User (user) User to Users (Users) Group

    ```bash
    aws iam add-user-to-group --group-name Users --user-name user \
                              --profile $PROFILE --region $REGION --output text
    ```

28. Create Demo (demo) Account User (user) User Login Profile

    This allows the Demo Account User User to login to the console.

    ```bash
    aws iam create-login-profile --user-name user --password demo123-user \
                                 --profile $PROFILE --region $REGION --output text
    ```

29. Create Demo (demo) Account User (user) User Access Key

    This allows the Demo Account User User to run API commands.

    ```bash
    mkdir -p ~/.creds/$REGION/demo/user

    result=$(aws iam create-access-key --user-name user \
                                       --query 'AccessKey.{AccessKeyId:AccessKeyId,SecretAccessKey:SecretAccessKey}' \
                                       --profile $PROFILE --region $REGION --output text)
    read access_key secret_key <<< "$result"

    cat << EOF > ~/.creds/$REGION/demo/user/iamrc
    AWSAccessKeyId=$access_key
    AWSSecretKey=$secret_key
    EOF
    ```

30. Create Demo (demo) Account User (user) User Euca2ools Profile

    This allows the Demo Account User User to run API commands via Euca2ools.

    ```bash
    cat << EOF >> ~/.euca/$REGION.ini
    [user $REGION-demo-user]
    key-id = $access_key
    secret-key = $secret_key

    EOF

    euca-describe-availability-zones --region $REGION-demo-user@$REGION
    ```

31. Create Demo (demo) Account User (user) User AWSCLI Profile

    This allows the Demo Account Demo User to run AWSCLI commands.

    ```bash
    cat << EOF >> ~/.aws/config
    [profile $REGION-demo-user]
    region = $REGION
    output = text

    EOF

    cat << EOF >> ~/.aws/credentials
    [$REGION-demo-user]
    aws_access_key_id = $access_key
    aws_secret_access_key = $secret_key

    EOF

    aws ec2 describe-availability-zones --profile $REGION-demo-user --region $REGION --output text
    ```

32. List Demo Resources

    ```bash
    aws ec2 describe-images

    aws ec2 describe-key-pairs

    aws iam list-roles --profile $PROFILE --region $REGION --output text
    aws iam list-instance-profiles --profile $PROFILE --region $REGION --output text
    aws iam get-instance-profile --instance-profile-name Demos --profile $PROFILE --region $REGION --output text

    aws iam list-groups --profile $PROFILE --region $REGION --output text

    aws iam list-users --profile $PROFILE --region $REGION --output text

    aws iam get-group --group-name Demos --profile $PROFILE --region $REGION --output text
    aws iam get-group --group-name Developers --profile $PROFILE --region $REGION --output text
    aws iam get-group --group-name Users --profile $PROFILE --region $REGION --output text
    ```

33. Display Euca2ools Configuration

    ```bash
    cat ~/.euca/global.ini

    cat /etc/euca2ools/conf.d/$REGION.ini

    cat ~/.euca/$REGION.ini
    ```

34. Display AWSCLI Configuration

    ```bash
    cat ~/.aws/config

    cat ~/.aws/credentials
    ```

