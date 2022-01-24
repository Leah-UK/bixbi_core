Config = {}

Config.NotifyType = "mythic_notify" -- Options = t-notify, esx, mythic_notify, okokNotify
Config.LoadingType = "mythic" -- Options = mythic, pogress, none
Config.VersionChecks = true -- When true bixbi addons will check for latest versions once every 2 hours.
Config.OxInventory = true -- When true, ox inventory related exports will work.

Config.IllegalTaskBlacklist = {
    -- Jobs in here cannot perform illegal tasks, if the script checks for it. Such as drug collection / selling.
    police = {},
    ambulance = {},
    mechanic = {}
}
