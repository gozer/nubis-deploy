output CredstashKeyID {
    # XXX: Somehow, the correct way to build this would be with the chain:
    #  - list(module.us-east-1.CredstashKeyID, module.us-west-2.CredstashKeyID)
    #  - compact() to remove empty ones
    #  - join(",") to make a final coma delimited list
    # But somehow, this doesn't work and causes TF to not even try and interpolate the variable ?!
    value = "${module.us-east-1.CredstashKeyID},${module.us-west-2.CredstashKeyID}"
}

output CredstashDynamoDB {
    value = "${module.us-east-1.CredstashDynamoDB},${module.us-west-2.CredstashKeyID}"
}
