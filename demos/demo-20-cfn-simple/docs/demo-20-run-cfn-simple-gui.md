# Demo 20: CloudFormation: Simple

This document describes the manual procedure to run the CloudFormation Simple demo via the GUI.

This script will use the Eucalyptus Console for the hp-gol01-f1 region, located here:
https://console.hp-gol01-f1.mjc.prc.eucalyptus-systems.com, in the commands and screen shots
below. Adjust as needed to your own system.

A demo account should have been created and initialized in advance. This account can be
created with any name, allowing for multiple demo accounts. The instructions below assume
the demo account was created with the name "demo".

You should have a copy of the "euca-demo" GitHub project checked out to the workstation 
where you will be running any Browser which will access the Eucalyptus Console, so that
you can upload any templates or other files which may be needed. This project should be
checked out to the ~/src/eucalyptus/euca-demo directory.

Prior to running this demo, please run the demo-20-initialize-cfn-simple.sh script, which
will confirm that all dependencies exist and perform any demo-specific initialization
required.

### Run CloudFormation Simple Demo via the Eucalyptus Console

1. Login to the Eucalyptus Console as the Demo Account Administrator

    Using your browser, open the appropriate [Eucalyptus Console](https://console.hp-aw2-1.hpcloudsvc.com).

    ![Login as Demo Account Administrator](../images/demo-20-run-cfn-simple-01-login.png?raw=true)

2. Confirm existence of Demo depencencies

    From the Dashboard, use the top left Navigation icon to display the left Navigation Panel.

    ![Dashboard with Navigation](../images/demo-20-run-cfn-simple-02-dashboard.png?raw=true)

    Then, Select Images to View Images which the Demo Account can use.
    Confirm the "centos66" image exists.

    ![View Images](../images/demo-20-run-cfn-simple-02-images.png?raw=true)

    From the Dashboard, Select the Key pairs Tile to View Key Pairs in the Demo Account.
    Confirm the "demo" Key Pair exists.

    ![View Key Pairs](../images/demo-20-run-cfn-simple-02-key-pairs.png?raw=true)

3. List initial Resources

    From the Dashboard, Select the Security groups Tile to View Security Groups in the
    Demo Account. Note contents of list for comparison after creating Stack.

    ![View Security Groups](../images/demo-20-run-cfn-simple-03-security-groups.png?raw=true)

    From the Dashboard, Select the Running instances Tile to View Instances in the
    Demo Account. Note contents of list for comparison after creating Stack.

    ![View Instances](../images/demo-20-run-cfn-simple-03-instances.png?raw=true)

4. List initial CloudFormation Stacks

    From the Dashboard, Select the Stacks Tile to View CloudFormation Stacks in the
    Demo Account. Note contents of list for comparison after creating Stack.

    ![View Stacks](../images/demo-20-run-cfn-simple-04-stacks.png?raw=true)

5. Display Simple CloudFormation template

    In another browser tab, open the [Simple.template](../templates/Simple.template) to view the Simple
    CloudFormation template we will use in this demo.

    ![View Simple.template](../images/demo-20-run-cfn-simple-05-simple-template.png?raw=true)

6. Create the Stack

    Return to the Eucalyptus Console, where you should still be on the Stacks Page. Click the
    Create Button to create a new CloudFormation Stack. Enter "SimpleDemoStack" as the Name.
    
    Next, click on the Upload template Radio Button, then the Choose File Button. Find and
    select ~/src/eucalyptus/euca-demo/demos/demo-20-cfn-simple/templates/Simple.template.

    ![Create Stack - General](../images/demo-20-run-cfn-simple-06-create-general.png?raw=true)

    Press the Next Button to advance to the Parameters Page. Select "centos66" as the DemoImageId,
    and "demo" as the DemoKeyPair.

    ![Create Stack - Parameters](../images/demo-20-run-cfn-simple-06-create-parameters.png?raw=true)

    Press the CreateStack Button to initiate Stack creation.

7. Monitor Stack creation

    Initiating Stack creation will automatically take you to the Stack General Tab, showing a 
    periodically updating view of the state of the stack objects. Review Stack status.

    ![Stack - General](../images/demo-20-run-cfn-simple-07-stack-01-details.png?raw=true)

    Click on the Events Tab. Review Stack Events.

    ![Stack - Events](../images/demo-20-run-cfn-simple-07-stack-01-events.png?raw=true)

    Click on the General Tab. Continue to monitor Stack Details until you notice the Stack is
    Completed.

    ![Stack - General](../images/demo-20-run-cfn-simple-07-stack-02-details.png?raw=true)

    Click on the Events Tab. Confirm all Events.

    ![Stack - Events](../images/demo-20-run-cfn-simple-07-stack-02-events.png?raw=true)

8. List updated Resources

    From the Dashboard, Select the Security groups Tile to View Security Groups in the
    Demo Account. Note updated contents of list, and compare with the initial set.

    ![View Security Groups](../images/demo-20-run-cfn-simple-08-security-groups.png?raw=true)

    From the Dashboard, Select the Running instances Tile to View Instances in the
    Demo Account. Note updated contents of list, and compare with the initial set.

    ![View Instances](../images/demo-20-run-cfn-simple-08-instances.png?raw=true)

    From the Instances page, Select the instance just created. Note the Public hostname,
    then select and copy it to the paste buffer for use in the next step.

    ![View Instance Details](../images/demo-20-run-cfn-simple-08-instance-details.png?raw=true)

9. Confirm ability to login to Instance

    Confirm you have the demo private key installed: ~/.ssh/demo_id_rsa. This file can
    be found [here](../../../keys/demo_id_rsa). Adjust the ssh command line as needed if
    you store your keys in a different location.

    From a separate ssh terminal application, use a command such as the following
    to login to the instance, replacing the public name shown with that observed in
    the instance details page.

    ```bash
    ssh -i ~/.ssh/demo_id_rsa centos@euca-15-185-206-78.eucalyptus.hp-aw2-1.hpcloudsvc.com
    ```

    Once you have successfully logged into the new instance. Confirm the private IP, then
    the public IP via the meta-data service, with the following commands:

    ```bash
    ifconfig

    curl http://169.254.169.254/latest/meta-data/public-ipv4; echo
    ```

    ![Verify Instance](../images/demo-20-run-cfn-simple-09-validate.png?raw=true)

### CloudFormation Simple Demo Key Points

The following are key points illustrated in this demo:

* This demo demonstrates use of CloudFormation via a Simple template, and is intended as an
  introduction to this feature in Eucalyptus.
* It is possible to view, run and monitor activities and resources created by CloudFormation
  via the Command line, or now within the Eucalyptus Console.
