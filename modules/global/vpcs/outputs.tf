output CredstashKeyID {
    # FIXME: we copy paste this module twice and I can't really figure out why
    # ${join("," ${module.*.CredstashKeyID} doesn't work so we are listing it this way for now
    value   = "${list("${module.us-east-1.CredstashKeyID}", "${module.us-west-2.CredstashKeyID}")}"
}

output CredstashDynamoDB {
    # FIXME: See above
    value = "${list("${module.us-east-1.CredstashDynamoDB}", "${module.us-west-2.CredstashKeyID}")}"
}
