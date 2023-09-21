require('dotenv').config();

const express = require('express');
const app = express();

const AWS = require('aws-sdk');

// port on which the server listens
const port = process.env.PORT;
const region = process.env.REGION;
const accessKeyId = process.env.ACCESS_KEY;
const secretAccessKey = process.env.SECRET_ACCESS_KEY;
const TableName = process.env.TABLE_NAME;

let client = new AWS.DynamoDB({
    region: region,
    accessKeyId: accessKeyId,
    secretAccessKey: secretAccessKey,
});

let count = -1;
let max = -1;
let req_count = 0;

function returnListPage(req, res) {
    req_count++;
    client.scan({ TableName }, async (err, data) => {
        res.contentType = 'text/html; charset=utf-8';

        if (err) {
            console.log(err);
            res.write('<!DOCTYPE html> ');
            res.write('<html lang="en"><body> ERROR. See server logs for more info. </body></html>');

        } else {
            if (count==-1) count = data.Items.length;

            const items = [];
            for (const i in data.Items) {
                items.push(data.Items[i]['DATA'].S);
                if (max < data.Items[i]['SORT_KEY'].N) max = data.Items[i]['SORT_KEY'].N;
                if (req_count >= 20) {
                    await new Promise((resolve, _reject) => {
                        setTimeout(() => resolve(null), 10);  // NO_CHECK_IN add delay of 10ms per record to test latency
                    });
                }
            }

            // send the obtained rows onto the response

            res.write(`

<!DOCTYPE html>
<html lang="en">
  <head>
    <title>Simple Node Server as Terraform and Maeztro Demo</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.4/jquery.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
  </head>
  <body>
    <div class="container">
        <h2 style="margin-top: 24pt;">Node Server</h2>
        <div class="well">
            <p>Hello. I am a simple Node server managed by Maeztro.</p>
            <p>I am connecting to a DynamoDB table and retrieving data. ${items.length} items found.</p>
            
            <form action="/add" method="post">
                <button name="add_record" value="true">Add Item</button>
            </form>
            <br/>
            
            `);

            if(items.length !== 0) {
                res.write(`

            <table class="table table-hover table-striped">
                <thead><tr><td>Here is the data:</td></tr></thead>
                <tbody>${items.map(item => `
                  <tr><td>${item}</tr></td>`).join('')}
                </tbody>
            </table>
            
                `);
            } else {
                res.write(`
            <p>There is no data.</p>
                `);
            }
            res.write(`

        </div>
    </div>
  </body>
</html>
            `);
        }

        res.end();
    });
};

app.get("/", returnListPage)

app.get("/request-count" , (req, res) => {
    res.write(`${req_count}`);
    res.end();
});

app.post("/add", (req, res) => {
    client.putItem(
        {
            TableName,
            "Item": {
                "HASH_KEY": {"S": "web"},
                "SORT_KEY": {"N": `${++max}`},
                "DATA": {"S": `web added record ${max}`},
            }
        },
        (err, data) => {
            if (err) console.warn("ERR", err);
            res.redirect('/');
        });
});


app.listen(port, () => {
    console.log(`Listening on port ${port}`);
});