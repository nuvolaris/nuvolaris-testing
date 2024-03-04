/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */
async function main(args) {
    // connect to the redis database
    const db = require("redis").createClient({"url":args.redis_url})
    await db.connect()
    let p = args.redis_prefix
    let str =  (Math.random() + 1).toString(36).substring(7);
    let key = `${p}${str}`


    await db.set(key, "world "+str)
    let res = await db.get(key)
    await db.del(key)
    await db.disconnect();

    return ({
        "hello": res
    });
}