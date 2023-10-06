
# Managing with Maeztro

This simple Terraform deployment introduced in the previous section can be imported in Maeztro.

First, download the Maeztro CLI for your environment from the Maeztro UI.

Then, set the `MZ_AMP_SERVER_URL` environment variable pointing to your Maeztro UI. For example:

```
export MZ_AMP_SERVER_URL=https://admin:password@10.0.1.100
```

**Note:** This is a temporary step. Support for the CLI to cache credentials securely is in development.

**Note:** We will create and edit Maeztro files during this tutorial and use the CLI to send them to the server. You can edit the files at each step, or if you prefer, commands to copy across the changed files are included at the bottom of each page.

Next, in a shell in the directory where this project resides, where you checked out and ran `terraform`, now run:

```shell
mz init --nickname node-with-dynamo
```

This will register the project with the Maeztro server. The nickname is optional and makes it easier to identify the application. You should see output like:

```
Creating a new Maeztro project from folder: /Users/user/projects/node-with-dynamo/deploy

Requested project name is: node-with-dynamo

Terraform files detected. Enabling terraform.

Terraform is configured as follows:
Terraform backend mode detected as 'none'.
To avoid conflicts it is recommended that Maeztro be configured to run Terraform 
only at the Maeztro server, or only locally with less server-side automation.
A Terraform backend will enable more flexible Terraform invocation.
Terraform will be configured with Terraform automatically running client-side 
(and manual runs also allowed) but not enabled at the Maeztro server.
Terraform refresh period will be set to the default of 6h.

Is this section correct? (y/n; default: yes): 
```

Press enter or type `yes` to proceed. Because we are not using a hosted backend such as Terraform cloud, to avoid state becoming out of sync, Maeztro is conservatively choosing not to try to run Terraform at the server-side. It will run Terraform client-side, or you can run it manually. Other configurations are available -- if you enter `no` you can change these settings.

You should then see Maeztro upload the files and refreshed state to the server, describing its processes and concluding with:

```
View status online at: http://maeztro-server/maeztro-ui-war/#/app/app-buL5LfZ0wNhH
```

Open this URL to see the application in the Maeztro UI:

![init-with-maeztro](imgs/2-1-init.png)

Maeztro is aware of the runtime state, as you can see, and the source code behind it; and can show drift in state or planned "unapplied" changes. Initially, it shows some default selected information, grouped based on the module structure and `count`/`foreach` resources. Here, the `aws_dynamodb_table_item` resources were created with `count=3`. The true power of Maeztro is in combining this information with the application's topology, then capturing operations as code alongside the relevant part of the model.

We will start modeling the topology by grouping resources according to the application's architecture. 

**Note:** The `mz init` operation creates a `.mz_state` directory in the project where local Maeztro state is stored. This directory should typically be added to `.gitignore` or similar. You can run `mz init` at any time to modify the configuration stored here. 

## Grouping

Let us start by making a simple new group at the server. Click "Edit", then drag from "New Group" onto your canvas. A new "Maeztro" resource is created: this exists only in the Maeztro system, not anywhere in the cloud, but provides a place to define the structure and operations which AMP/Maeztro looks after.

For example, we can define a name for this resource: click on the new group, then edit the title at the right to be `Web`. More interestingly, we can drag the four `node_server` resources onto this to group them, and declare a nicer name for one of them, for example renaming the `aws_instance` as `Web Server`. Once you've saved and exited, you should see something like this:

![grouped-web](imgs/2-2-grouped-web.png)

The node is shown green because the changes have not been applied yet. To apply the changes, run `mz apply`. The UI refreshes and the `Web` node is now shown in white, indistinguishable from the other nodes in the application.

As we've been doing this, Maeztro has updated files capturing this structure. Maeztro files have a `*.mz` suffix, and define "as code" the resources and extensions for management alongside your other infrastructure-as-code files. Building the Maeztro model -- by editing these files -- can be done either in the Maztro UI or on your local system. The CLI `mz sync` command can be used to synchronize these changes.

Download the updated files to your folder now, by running `mz sync`.  You will see a message that an `main.mz` file created locally. This file should look something like this:

```hcl
# Web Group
resource "maeztro" "web" {
  name = "Web"
}
maeztro extend resource "aws_instance.node_server" {
  name = "Web Server"
  parent = maeztro.web
}
maeztro extend resource "aws_key_pair.node_server" {
  parent = maeztro.web
}
maeztro extend resource "aws_security_group.node_server" {
  parent = maeztro.web
}
maeztro extend resource "aws_eip.node_server" {
  parent = maeztro.web
}
```

Notice we defined one new resource and extended the four that Terraform defined, in a format similar to Terraform. The Terraform files are unchanged, and you can continue to use Terraform without interference from the Maeztro files. Maeztro can be opted-in at any point to give a richer view of the system. Shortly we will enrich these even more, with sensors, effectors, and policies.  But for now let us continue grouping.

Your file may have some additional positioning information, and don't worry if it doesn't look exactly the same. Try renaming `main.mz` as `nodejs-server.mz` to align with the Terraform filenames, and change the `name` attributes or set them for the other extended resources.

To upload these changes back to the server and preview them, simply run `mz sync`. If you make changes at the server, the same command will pull them down.

**Note:** If changes are made in both sites, the `mz` command will warn you and ask you which ones you want to keep. Maeztro does not attempt conflict resolution, as this is easy enough with `git` or another source control tool. For example: `git stash` followed by a `mz run --tracks files:pull --force` then `git stash pop`.

You can run `mz apply` to activate the changes, or do this via the UI as we did previously. In this example, as we are not running Terraform at the server, so a UI apply will not re-run Terraform but the CLI will. If Terraform Cloud or another backend is used, Terraform can be run safely in either location. We aren't changing the Terraform here, so it doesn't matter.

The application in this tutorial has two main components: the web server and the DynamoDB table. In addition, there are the data table items two miscellaneous resource, the `random` used to give a unique prefix and the SSH key. We suggest grouping the resources as follows:

- `nodejs-server.mz` - web components in a group (the EC2, the security group and the elastic IP resources)
- `dynamo-table.mz` - a data tier group (the DynamoDB table and its access policy) and the data items group (already populated)
- `misc.mz` - the random string and the key

For example it could look like this:

![grouped-all](imgs/2-3-grouped-all.png)

Feel free to group things differently. There is not one universal right way.  In general, this should be a structure that is useful for understanding and, as we will see, for collecting sensors and running effectors; for this exercise the grouping does not matter. It is also easy to change later. Edit and create local files, `mz sync` to send to the server to preview or edit further, and `mz sync` to bring back. See the note above if you encounter conflicts. When you're happy, `mz apply` to roll them out.

If you have difficulties, or just want to move on, you can copy and install pre-made files as follows:

```
rm *.mz
cp ../stages/2-grouping/*.mz ./
mz apply
```

Now that we have our resources grouped, the application is ready for [the next step in the tutorial](3-sensors.md), using Maeztro to pull in "sensor" telemetry from various sources to the relevant resources.
