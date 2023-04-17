function main(args) {
    let name = args.name || "World"
    return {
        "body": "Hello, "+name
    }
}