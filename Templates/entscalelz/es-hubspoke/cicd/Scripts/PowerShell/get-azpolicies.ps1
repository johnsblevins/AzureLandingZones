$assignments = Get-AzPolicyAssignment

foreach ($assignment in $assignments)
{
    $assignment.name
}