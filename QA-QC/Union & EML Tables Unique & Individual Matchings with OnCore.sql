alter view qc.Union_And_EML_Unique_And_Individual_Matching as
    with UnionTable as (select distinct FIRST_NAME, LAST_NAME, EMAIL_ADDR, NETID_OPRID
                        from dtrust_proxy.med_faculty_union)
       , EMLTable as (select distinct FIRST_NAME, LAST_NAME, EMAIL_ADDR, NETID_OPRID from dtrust_proxy.med_faculty_eml)

       , Current_PIs as (select distinct pi_name,
                                         dbo.GetNetIDFromEmail(pi_email) Protocols_PI_Email_Prefix
                         from protocols
                         where pi_name is not null
                           and Current_Status != 'ABANDONED'
                           and (
                             (year(Current_Status_Date) >= year(getdate()) - 5 and
                              Current_Status in ('IRB STUDY CLOSURE', 'TERMINATED'))
                                 or
                             Current_Status in ('IRB INITIAL APPROVAL',
                                                'UAHS RA SIGNOFF',
                                                'ON HOLD',
                                                'NEW',
                                                'SRC APPROVAL',
                                                'CLOSED TO ACCRUAL',
                                                'OPEN TO ACCRUAL',
                                                'SUSPENDED'
                                 )
                             ))
       , FilteredStaff as (select distinct s.STAFF_NAME, s.EMAIL_ADDRESS, NETID, Username
                           from Staff s
                                    join Current_PIs pi
                                         on pi.pi_name = s.STAFF_NAME)
       , FilteredStaffCount as (select count(distinct staff_name) staffCount from FilteredStaff)


       , MatchingsMatrix as (select s.STAFF_NAME,
                                    iif(u.LAST_NAME + ', ' + u.FIRST_NAME = s.STAFF_NAME, s.STAFF_NAME,
                                        null)                                           [OnCore --> Union: FullName --> FullName],
                                    iif(dbo.GetNetIDFromEmail(s.EMAIL_ADDRESS) = u.NETID_OPRID, s.STAFF_NAME,
                                        null)                                           [OnCore --> Union: Prefix --> NetID],
                                    iif(dbo.GetNetIDFromEmail(s.EMAIL_ADDRESS) = dbo.GetNetIDFromEmail(u.EMAIL_ADDR),
                                        s.STAFF_NAME,
                                        null)                                           [OnCore --> Union: Username --> Prefix],
                                    iif(u.NETID_OPRID = s.Username, s.STAFF_NAME, null) [OnCore --> Union: Prefix --> Prefix],
                                    iif(s.NETID = u.NETID_OPRID, s.STAFF_NAME, null)    [OnCore --> Union: NetID --> NetID],
                                    iif(e.LAST_NAME + ', ' + e.FIRST_NAME = s.STAFF_NAME, s.STAFF_NAME,
                                        null)                                           [OnCore --> EML: FullName --> FullName],
                                    iif(dbo.GetNetIDFromEmail(s.EMAIL_ADDRESS) = e.NETID_OPRID, s.STAFF_NAME,
                                        null)                                           [OnCore --> EML: Prefix --> NetID],
                                    iif(dbo.GetNetIDFromEmail(s.EMAIL_ADDRESS) = dbo.GetNetIDFromEmail(e.EMAIL_ADDR),
                                        s.STAFF_NAME,
                                        null)                                           [OnCore --> EML: Username --> Prefix],
                                    iif(e.NETID_OPRID = s.Username, s.STAFF_NAME, null) [OnCore --> EML: Prefix --> Prefix],
                                    iif(s.NETID = e.NETID_OPRID, s.STAFF_NAME, null)    [OnCore --> EML: NetID --> NetID]
                             from FilteredStaff s
                                      left join UnionTable u
                                                on u.LAST_NAME + ', ' + u.FIRST_NAME = s.STAFF_NAME
                                                    or dbo.GetNetIDFromEmail(s.EMAIL_ADDRESS) = u.NETID_OPRID
                                                    or
                                                   dbo.GetNetIDFromEmail(s.EMAIL_ADDRESS) =
                                                   dbo.GetNetIDFromEmail(u.EMAIL_ADDR)
                                                    or u.NETID_OPRID = s.Username
                                                    or s.NETID = u.NETID_OPRID
                                      left join EMLTable e
                                                on e.LAST_NAME + ', ' + e.FIRST_NAME = s.STAFF_NAME
                                                    or dbo.GetNetIDFromEmail(s.EMAIL_ADDRESS) = e.NETID_OPRID
                                                    or
                                                   dbo.GetNetIDFromEmail(s.EMAIL_ADDRESS) =
                                                   dbo.GetNetIDFromEmail(e.EMAIL_ADDR)
                                                    or e.NETID_OPRID = s.Username
                                                    or s.NETID = e.NETID_OPRID)

       , UniqueMatchingsCount as (select count(case
                                                   when [OnCore --> Union: Prefix --> NetID] is not null
                                                       and [OnCore --> Union: NetID --> NetID] is null
                                                       and [OnCore --> Union: FullName --> FullName] is null
                                                       and [OnCore --> Union: Prefix --> Prefix] is null
                                                       and [OnCore --> Union: Username --> Prefix] is null
                                                       and [OnCore --> EML: Prefix --> NetID] is null
                                                       and [OnCore --> EML: NetID --> NetID] is null
                                                       and [OnCore --> EML: FullName --> FullName] is null
                                                       and [OnCore --> EML: Prefix --> Prefix] is null
                                                       and [OnCore --> EML: Username --> Prefix] is null
                                                       then [OnCore --> Union: Prefix --> NetID] end
                                         ) as [OnCore --> Union: Prefix --> NetID]
                                       , count(case
                                                   when [OnCore --> Union: Prefix --> NetID] is null
                                                       and [OnCore --> Union: NetID --> NetID] is not null
                                                       and [OnCore --> Union: FullName --> FullName] is null
                                                       and [OnCore --> Union: Prefix --> Prefix] is null
                                                       and [OnCore --> Union: Username --> Prefix] is null
                                                       and [OnCore --> EML: Prefix --> NetID] is null
                                                       and [OnCore --> EML: NetID --> NetID] is null
                                                       and [OnCore --> EML: FullName --> FullName] is null
                                                       and [OnCore --> EML: Prefix --> Prefix] is null
                                                       and [OnCore --> EML: Username --> Prefix] is null
                                                       then [OnCore --> Union: NetID --> NetID] end
                                         ) as [OnCore --> Union: NetID --> NetID]
                                       , count(case
                                                   when [OnCore --> Union: Prefix --> NetID] is null
                                                       and [OnCore --> Union: NetID --> NetID] is null
                                                       and [OnCore --> Union: FullName --> FullName] is not null
                                                       and [OnCore --> Union: Prefix --> Prefix] is null
                                                       and [OnCore --> Union: Username --> Prefix] is null
                                                       and [OnCore --> EML: Prefix --> NetID] is null
                                                       and [OnCore --> EML: NetID --> NetID] is null
                                                       and [OnCore --> EML: FullName --> FullName] is null
                                                       and [OnCore --> EML: Prefix --> Prefix] is null
                                                       and [OnCore --> EML: Username --> Prefix] is null
                                                       then [OnCore --> Union: FullName --> FullName] end
                                         ) as [OnCore --> Union: FullName --> FullName]
                                       , count(case
                                                   when [OnCore --> Union: Prefix --> NetID] is null
                                                       and [OnCore --> Union: NetID --> NetID] is null
                                                       and [OnCore --> Union: FullName --> FullName] is null
                                                       and [OnCore --> Union: Prefix --> Prefix] is not null
                                                       and [OnCore --> Union: Username --> Prefix] is null
                                                       and [OnCore --> EML: Prefix --> NetID] is null
                                                       and [OnCore --> EML: NetID --> NetID] is null
                                                       and [OnCore --> EML: FullName --> FullName] is null
                                                       and [OnCore --> EML: Prefix --> Prefix] is null
                                                       and [OnCore --> EML: Username --> Prefix] is null
                                                       then [OnCore --> Union: Prefix --> Prefix] end
                                         ) as [OnCore --> Union: Prefix --> Prefix]
                                       , count(case
                                                   when [OnCore --> Union: Prefix --> NetID] is null
                                                       and [OnCore --> Union: NetID --> NetID] is null
                                                       and [OnCore --> Union: FullName --> FullName] is null
                                                       and [OnCore --> Union: Prefix --> Prefix] is null
                                                       and [OnCore --> Union: Username --> Prefix] is not null
                                                       and [OnCore --> EML: Prefix --> NetID] is null
                                                       and [OnCore --> EML: NetID --> NetID] is null
                                                       and [OnCore --> EML: FullName --> FullName] is null
                                                       and [OnCore --> EML: Prefix --> Prefix] is null
                                                       and [OnCore --> EML: Username --> Prefix] is null
                                                       then [OnCore --> Union: Username --> Prefix] end
                                         ) as [OnCore --> Union: Username --> Prefix]
                                       , count(case
                                                   when [OnCore --> Union: Prefix --> NetID] is null
                                                       and [OnCore --> Union: NetID --> NetID] is null
                                                       and [OnCore --> Union: FullName --> FullName] is null
                                                       and [OnCore --> Union: Prefix --> Prefix] is null
                                                       and [OnCore --> Union: Username --> Prefix] is null
                                                       and [OnCore --> EML: Prefix --> NetID] is not null
                                                       and [OnCore --> EML: NetID --> NetID] is null
                                                       and [OnCore --> EML: FullName --> FullName] is null
                                                       and [OnCore --> EML: Prefix --> Prefix] is null
                                                       and [OnCore --> EML: Username --> Prefix] is null
                                                       then [OnCore --> EML: Prefix --> NetID] end
                                         ) as [OnCore --> EML: Prefix --> NetID]
                                       , count(case
                                                   when [OnCore --> Union: Prefix --> NetID] is null
                                                       and [OnCore --> Union: NetID --> NetID] is null
                                                       and [OnCore --> Union: FullName --> FullName] is null
                                                       and [OnCore --> Union: Prefix --> Prefix] is null
                                                       and [OnCore --> Union: Username --> Prefix] is null
                                                       and [OnCore --> EML: Prefix --> NetID] is null
                                                       and [OnCore --> EML: NetID --> NetID] is not null
                                                       and [OnCore --> EML: FullName --> FullName] is null
                                                       and [OnCore --> EML: Prefix --> Prefix] is null
                                                       and [OnCore --> EML: Username --> Prefix] is null
                                                       then [OnCore --> EML: NetID --> NetID] end
                                         ) as [OnCore --> EML: NetID --> NetID]
                                       , count(case
                                                   when [OnCore --> Union: Prefix --> NetID] is null
                                                       and [OnCore --> Union: NetID --> NetID] is null
                                                       and [OnCore --> Union: FullName --> FullName] is null
                                                       and [OnCore --> Union: Prefix --> Prefix] is null
                                                       and [OnCore --> Union: Username --> Prefix] is null
                                                       and [OnCore --> EML: Prefix --> NetID] is null
                                                       and [OnCore --> EML: NetID --> NetID] is null
                                                       and [OnCore --> EML: FullName --> FullName] is not null
                                                       and [OnCore --> EML: Prefix --> Prefix] is null
                                                       and [OnCore --> EML: Username --> Prefix] is null
                                                       then [OnCore --> EML: FullName --> FullName] end
                                         ) as [OnCore --> EML: FullName --> FullName]
                                       , count(case
                                                   when [OnCore --> Union: Prefix --> NetID] is null
                                                       and [OnCore --> Union: NetID --> NetID] is null
                                                       and [OnCore --> Union: FullName --> FullName] is null
                                                       and [OnCore --> Union: Prefix --> Prefix] is null
                                                       and [OnCore --> Union: Username --> Prefix] is null
                                                       and [OnCore --> EML: Prefix --> NetID] is null
                                                       and [OnCore --> EML: NetID --> NetID] is null
                                                       and [OnCore --> EML: FullName --> FullName] is null
                                                       and [OnCore --> EML: Prefix --> Prefix] is not null
                                                       and [OnCore --> EML: Username --> Prefix] is null
                                                       then [OnCore --> EML: Prefix --> Prefix] end
                                         ) as [OnCore --> EML: Prefix --> Prefix]
                                       , count(case
                                                   when [OnCore --> Union: Prefix --> NetID] is null
                                                       and [OnCore --> Union: NetID --> NetID] is null
                                                       and [OnCore --> Union: FullName --> FullName] is null
                                                       and [OnCore --> Union: Prefix --> Prefix] is null
                                                       and [OnCore --> Union: Username --> Prefix] is null
                                                       and [OnCore --> EML: Prefix --> NetID] is null
                                                       and [OnCore --> EML: NetID --> NetID] is null
                                                       and [OnCore --> EML: FullName --> FullName] is null
                                                       and [OnCore --> EML: Prefix --> Prefix] is null
                                                       and [OnCore --> EML: Username --> Prefix] is not null
                                                       then [OnCore --> EML: Username --> Prefix] end
                                         ) as [OnCore --> EML: Username --> Prefix]

                                  from MatchingsMatrix)
       , UniqueMatchings as (select case
                                        when [OnCore --> Union: Prefix --> NetID] is not null
                                            and [OnCore --> Union: NetID --> NetID] is null
                                            and [OnCore --> Union: FullName --> FullName] is null
                                            and [OnCore --> Union: Prefix --> Prefix] is null
                                            and [OnCore --> Union: Username --> Prefix] is null
                                            and [OnCore --> EML: Prefix --> NetID] is null
                                            and [OnCore --> EML: NetID --> NetID] is null
                                            and [OnCore --> EML: FullName --> FullName] is null
                                            and [OnCore --> EML: Prefix --> Prefix] is null
                                            and [OnCore --> EML: Username --> Prefix] is null
                                            then [OnCore --> Union: Prefix --> NetID] end
        as [OnCore --> Union: Prefix --> NetID]
                                  , case
                                        when [OnCore --> Union: Prefix --> NetID] is null
                                            and [OnCore --> Union: NetID --> NetID] is not null
                                            and [OnCore --> Union: FullName --> FullName] is null
                                            and [OnCore --> Union: Prefix --> Prefix] is null
                                            and [OnCore --> Union: Username --> Prefix] is null
                                            and [OnCore --> EML: Prefix --> NetID] is null
                                            and [OnCore --> EML: NetID --> NetID] is null
                                            and [OnCore --> EML: FullName --> FullName] is null
                                            and [OnCore --> EML: Prefix --> Prefix] is null
                                            and [OnCore --> EML: Username --> Prefix] is null
                                            then [OnCore --> Union: NetID --> NetID] end
        as [OnCore --> Union: NetID --> NetID]
                                  , case
                                        when [OnCore --> Union: Prefix --> NetID] is null
                                            and [OnCore --> Union: NetID --> NetID] is null
                                            and [OnCore --> Union: FullName --> FullName] is not null
                                            and [OnCore --> Union: Prefix --> Prefix] is null
                                            and [OnCore --> Union: Username --> Prefix] is null
                                            and [OnCore --> EML: Prefix --> NetID] is null
                                            and [OnCore --> EML: NetID --> NetID] is null
                                            and [OnCore --> EML: FullName --> FullName] is null
                                            and [OnCore --> EML: Prefix --> Prefix] is null
                                            and [OnCore --> EML: Username --> Prefix] is null
                                            then [OnCore --> Union: FullName --> FullName] end
        as [OnCore --> Union: FullName --> FullName]
                                  , case
                                        when [OnCore --> Union: Prefix --> NetID] is null
                                            and [OnCore --> Union: NetID --> NetID] is null
                                            and [OnCore --> Union: FullName --> FullName] is null
                                            and [OnCore --> Union: Prefix --> Prefix] is not null
                                            and [OnCore --> Union: Username --> Prefix] is null
                                            and [OnCore --> EML: Prefix --> NetID] is null
                                            and [OnCore --> EML: NetID --> NetID] is null
                                            and [OnCore --> EML: FullName --> FullName] is null
                                            and [OnCore --> EML: Prefix --> Prefix] is null
                                            and [OnCore --> EML: Username --> Prefix] is null
                                            then [OnCore --> Union: Prefix --> Prefix] end
        as [OnCore --> Union: Prefix --> Prefix]
                                  , case
                                        when [OnCore --> Union: Prefix --> NetID] is null
                                            and [OnCore --> Union: NetID --> NetID] is null
                                            and [OnCore --> Union: FullName --> FullName] is null
                                            and [OnCore --> Union: Prefix --> Prefix] is null
                                            and [OnCore --> Union: Username --> Prefix] is not null
                                            and [OnCore --> EML: Prefix --> NetID] is null
                                            and [OnCore --> EML: NetID --> NetID] is null
                                            and [OnCore --> EML: FullName --> FullName] is null
                                            and [OnCore --> EML: Prefix --> Prefix] is null
                                            and [OnCore --> EML: Username --> Prefix] is null
                                            then [OnCore --> Union: Username --> Prefix] end
        as [OnCore --> Union: Username --> Prefix]
                                  , case
                                        when [OnCore --> Union: Prefix --> NetID] is null
                                            and [OnCore --> Union: NetID --> NetID] is null
                                            and [OnCore --> Union: FullName --> FullName] is null
                                            and [OnCore --> Union: Prefix --> Prefix] is null
                                            and [OnCore --> Union: Username --> Prefix] is null
                                            and [OnCore --> EML: Prefix --> NetID] is not null
                                            and [OnCore --> EML: NetID --> NetID] is null
                                            and [OnCore --> EML: FullName --> FullName] is null
                                            and [OnCore --> EML: Prefix --> Prefix] is null
                                            and [OnCore --> EML: Username --> Prefix] is null
                                            then [OnCore --> EML: Prefix --> NetID] end
        as [OnCore --> EML: Prefix --> NetID]
                                  , case
                                        when [OnCore --> Union: Prefix --> NetID] is null
                                            and [OnCore --> Union: NetID --> NetID] is null
                                            and [OnCore --> Union: FullName --> FullName] is null
                                            and [OnCore --> Union: Prefix --> Prefix] is null
                                            and [OnCore --> Union: Username --> Prefix] is null
                                            and [OnCore --> EML: Prefix --> NetID] is null
                                            and [OnCore --> EML: NetID --> NetID] is not null
                                            and [OnCore --> EML: FullName --> FullName] is null
                                            and [OnCore --> EML: Prefix --> Prefix] is null
                                            and [OnCore --> EML: Username --> Prefix] is null
                                            then [OnCore --> EML: NetID --> NetID] end
        as [OnCore --> EML: NetID --> NetID]
                                  , case
                                        when [OnCore --> Union: Prefix --> NetID] is null
                                            and [OnCore --> Union: NetID --> NetID] is null
                                            and [OnCore --> Union: FullName --> FullName] is null
                                            and [OnCore --> Union: Prefix --> Prefix] is null
                                            and [OnCore --> Union: Username --> Prefix] is null
                                            and [OnCore --> EML: Prefix --> NetID] is null
                                            and [OnCore --> EML: NetID --> NetID] is null
                                            and [OnCore --> EML: FullName --> FullName] is not null
                                            and [OnCore --> EML: Prefix --> Prefix] is null
                                            and [OnCore --> EML: Username --> Prefix] is null
                                            then [OnCore --> EML: FullName --> FullName] end
        as [OnCore --> EML: FullName --> FullName]
                                  , case
                                        when [OnCore --> Union: Prefix --> NetID] is null
                                            and [OnCore --> Union: NetID --> NetID] is null
                                            and [OnCore --> Union: FullName --> FullName] is null
                                            and [OnCore --> Union: Prefix --> Prefix] is null
                                            and [OnCore --> Union: Username --> Prefix] is null
                                            and [OnCore --> EML: Prefix --> NetID] is null
                                            and [OnCore --> EML: NetID --> NetID] is null
                                            and [OnCore --> EML: FullName --> FullName] is null
                                            and [OnCore --> EML: Prefix --> Prefix] is not null
                                            and [OnCore --> EML: Username --> Prefix] is null
                                            then [OnCore --> EML: Prefix --> Prefix] end
        as [OnCore --> EML: Prefix --> Prefix]
                                  , case
                                        when [OnCore --> Union: Prefix --> NetID] is null
                                            and [OnCore --> Union: NetID --> NetID] is null
                                            and [OnCore --> Union: FullName --> FullName] is null
                                            and [OnCore --> Union: Prefix --> Prefix] is null
                                            and [OnCore --> Union: Username --> Prefix] is null
                                            and [OnCore --> EML: Prefix --> NetID] is null
                                            and [OnCore --> EML: NetID --> NetID] is null
                                            and [OnCore --> EML: FullName --> FullName] is null
                                            and [OnCore --> EML: Prefix --> Prefix] is null
                                            and [OnCore --> EML: Username --> Prefix] is not null
                                            then [OnCore --> EML: Username --> Prefix] end
        as [OnCore --> EML: Username --> Prefix]

                             from MatchingsMatrix)
       , IndividualMatchingsCount as (select count(COALESCE([OnCore --> Union: Prefix --> NetID], null)
                                             ) as [OnCore --> Union: Prefix --> NetID]
                                           , count(COALESCE([OnCore --> Union: NetID --> NetID], null)
                                             ) as [OnCore --> Union: NetID --> NetID]
                                           , count(COALESCE([OnCore --> Union: FullName --> FullName], null)
                                             ) as [OnCore --> Union: FullName --> FullName]
                                           , count(COALESCE([OnCore --> Union: Prefix --> Prefix], null)
                                             ) as [OnCore --> Union: Prefix --> Prefix]
                                           , count(COALESCE([OnCore --> Union: Username --> Prefix], null)
                                             ) as [OnCore --> Union: Username --> Prefix]
                                           , count(COALESCE([OnCore --> EML: Prefix --> NetID], null)
                                             ) as [OnCore --> EML: Prefix --> NetID]
                                           , count(COALESCE([OnCore --> EML: NetID --> NetID], null)
                                             ) as [OnCore --> EML: NetID --> NetID]
                                           , count(COALESCE([OnCore --> EML: FullName --> FullName], null)
                                             ) as [OnCore --> EML: FullName --> FullName]
                                           , count(COALESCE([OnCore --> EML: Prefix --> Prefix], null)
                                             ) as [OnCore --> EML: Prefix --> Prefix]
                                           , count(COALESCE([OnCore --> EML: Username --> Prefix], null)
                                             ) as [OnCore --> EML: Username --> Prefix]

                                      from MatchingsMatrix)

    select 'Unique Matching' MatchingType
         , cast([OnCore --> Union: Prefix --> NetID] as varchar) + '/' +
           cast((select staffCount from FilteredStaffCount) as varchar) + ' : ' +
           format([OnCore --> Union: Prefix --> NetID]
                      / cast((select staffCount from FilteredStaffCount) as float),
                  'P2') as   [OnCore --> Union: Prefix --> NetID]
         , cast([OnCore --> Union: NetID --> NetID] as varchar) + '/' +
           cast((select staffCount from FilteredStaffCount) as varchar) + ' : ' +
           format([OnCore --> Union: NetID --> NetID]
                      / cast((select staffCount from FilteredStaffCount) as float),
                  'P2') as   [OnCore --> Union: NetID --> NetID]
         , cast([OnCore --> Union: FullName --> FullName] as varchar) + '/' +
           cast((select staffCount from FilteredStaffCount) as varchar) + ' : ' +
           format([OnCore --> Union: FullName --> FullName]
                      / cast((select staffCount from FilteredStaffCount) as float),
                  'P2') as   [OnCore --> Union: FullName --> FullName]
         , cast([OnCore --> Union: Prefix --> Prefix] as varchar) + '/' +
           cast((select staffCount from FilteredStaffCount) as varchar) + ' : ' +
           format([OnCore --> Union: Prefix --> Prefix]
                      / cast((select staffCount from FilteredStaffCount) as float),
                  'P2') as   [OnCore --> Union: Prefix --> Prefix]
         , cast([OnCore --> Union: Username --> Prefix] as varchar) + '/' +
           cast((select staffCount from FilteredStaffCount) as varchar) + ' : ' +
           format([OnCore --> Union: Username --> Prefix]
                      / cast((select staffCount from FilteredStaffCount) as float),
                  'P2') as   [OnCore --> Union: Username --> Prefix]
         , cast([OnCore --> EML: Prefix --> NetID] as varchar) + '/' +
           cast((select staffCount from FilteredStaffCount) as varchar) + ' : ' +
           format([OnCore --> EML: Prefix --> NetID]
                      / cast((select staffCount from FilteredStaffCount) as float),
                  'P2') as   [OnCore --> EML: Prefix --> NetID]
         , cast([OnCore --> EML: NetID --> NetID] as varchar) + '/' +
           cast((select staffCount from FilteredStaffCount) as varchar) + ' : ' +
           format([OnCore --> EML: NetID --> NetID]
                      / cast((select staffCount from FilteredStaffCount) as float),
                  'P2') as   [OnCore --> EML: NetID --> NetID]
         , cast([OnCore --> EML: FullName --> FullName] as varchar) + '/' +
           cast((select staffCount from FilteredStaffCount) as varchar) + ' : ' +
           format([OnCore --> EML: FullName --> FullName]
                      / cast((select staffCount from FilteredStaffCount) as float),
                  'P2') as   [OnCore --> EML: FullName --> FullName]
         , cast([OnCore --> EML: Prefix --> Prefix] as varchar) + '/' +
           cast((select staffCount from FilteredStaffCount) as varchar) + ' : ' +
           format([OnCore --> EML: Prefix --> Prefix]
                      / cast((select staffCount from FilteredStaffCount) as float),
                  'P2') as   [OnCore --> EML: Prefix --> Prefix]
         , cast([OnCore --> EML: Username --> Prefix] as varchar) + '/' +
           cast((select staffCount from FilteredStaffCount) as varchar) + ' : ' +
           format([OnCore --> EML: Username --> Prefix]
                      / cast((select staffCount from FilteredStaffCount) as float),
                  'P2') as   [OnCore --> EML: Username --> Prefix]
         , ''           as   [Zero Matching Contacts]
    from UniqueMatchingsCount

    union

    select 'Unique Matching Contacts' MatchingType
         , [OnCore --> Union: Prefix --> NetID]
         , [OnCore --> Union: NetID --> NetID]
         , [OnCore --> Union: FullName --> FullName]
         , [OnCore --> Union: Prefix --> Prefix]
         , [OnCore --> Union: Username --> Prefix]
         , [OnCore --> EML: Prefix --> NetID]
         , [OnCore --> EML: NetID --> NetID]
         , [OnCore --> EML: FullName --> FullName]
         , [OnCore --> EML: Prefix --> Prefix]
         , [OnCore --> EML: Username --> Prefix]
         , '' as                      [Zero Matching Contacts]
    from UniqueMatchings

    union

    select 'Individual Matching' MatchingType
         , cast([OnCore --> Union: Prefix --> NetID] as varchar) + '/' +
           cast((select staffCount from FilteredStaffCount) as varchar) + ' : ' +
           format([OnCore --> Union: Prefix --> NetID]
                      / cast((select staffCount from FilteredStaffCount) as float),
                  'P2') as       [OnCore --> Union: Prefix --> NetID]
         , cast([OnCore --> Union: NetID --> NetID] as varchar) + '/' +
           cast((select staffCount from FilteredStaffCount) as varchar) + ' : ' +
           format([OnCore --> Union: NetID --> NetID]
                      / cast((select staffCount from FilteredStaffCount) as float),
                  'P2') as       [OnCore --> Union: NetID --> NetID]
         , cast([OnCore --> Union: FullName --> FullName] as varchar) + '/' +
           cast((select staffCount from FilteredStaffCount) as varchar) + ' : ' +
           format([OnCore --> Union: FullName --> FullName]
                      / cast((select staffCount from FilteredStaffCount) as float),
                  'P2') as       [OnCore --> Union: FullName --> FullName]
         , cast([OnCore --> Union: Prefix --> Prefix] as varchar) + '/' +
           cast((select staffCount from FilteredStaffCount) as varchar) + ' : ' +
           format([OnCore --> Union: Prefix --> Prefix]
                      / cast((select staffCount from FilteredStaffCount) as float),
                  'P2') as       [OnCore --> Union: Prefix --> Prefix]
         , cast([OnCore --> Union: Username --> Prefix] as varchar) + '/' +
           cast((select staffCount from FilteredStaffCount) as varchar) + ' : ' +
           format([OnCore --> Union: Username --> Prefix]
                      / cast((select staffCount from FilteredStaffCount) as float),
                  'P2') as       [OnCore --> Union: Username --> Prefix]
         , cast([OnCore --> EML: Prefix --> NetID] as varchar) + '/' +
           cast((select staffCount from FilteredStaffCount) as varchar) + ' : ' +
           format([OnCore --> EML: Prefix --> NetID]
                      / cast((select staffCount from FilteredStaffCount) as float),
                  'P2') as       [OnCore --> EML: Prefix --> NetID]
         , cast([OnCore --> EML: NetID --> NetID] as varchar) + '/' +
           cast((select staffCount from FilteredStaffCount) as varchar) + ' : ' +
           format([OnCore --> EML: NetID --> NetID]
                      / cast((select staffCount from FilteredStaffCount) as float),
                  'P2') as       [OnCore --> EML: NetID --> NetID]
         , cast([OnCore --> EML: FullName --> FullName] as varchar) + '/' +
           cast((select staffCount from FilteredStaffCount) as varchar) + ' : ' +
           format([OnCore --> EML: FullName --> FullName]
                      / cast((select staffCount from FilteredStaffCount) as float),
                  'P2') as       [OnCore --> EML: FullName --> FullName]
         , cast([OnCore --> EML: Prefix --> Prefix] as varchar) + '/' +
           cast((select staffCount from FilteredStaffCount) as varchar) + ' : ' +
           format([OnCore --> EML: Prefix --> Prefix]
                      / cast((select staffCount from FilteredStaffCount) as float),
                  'P2') as       [OnCore --> EML: Prefix --> Prefix]
         , cast([OnCore --> EML: Username --> Prefix] as varchar) + '/' +
           cast((select staffCount from FilteredStaffCount) as varchar) + ' : ' +
           format([OnCore --> EML: Username --> Prefix]
                      / cast((select staffCount from FilteredStaffCount) as float),
                  'P2') as       [OnCore --> EML: Username --> Prefix]
         , ''           as       [Zero Matching Contacts]
    from IndividualMatchingsCount

    union

    select 'Zero Matching'                                                     as MatchingType
         , ''                                                                  as [OnCore --> Union: Prefix --> NetID]
         , ''                                                                  as [OnCore --> Union: NetID --> NetID]
         , ''                                                                  as [OnCore --> Union: FullName --> FullName]
         , ''                                                                  as [OnCore --> Union: Prefix --> Prefix]
         , ''                                                                  as [OnCore --> Union: Username --> Prefix]
         , ''                                                                  as [OnCore --> EML: Prefix --> NetID]
         , ''                                                                  as [OnCore --> EML: NetID --> NetID]
         , ''                                                                  as [OnCore --> EML: FullName --> FullName]
         , ''                                                                  as [OnCore --> EML: Prefix --> Prefix]
         , ''                                                                  as [OnCore --> EML: Username --> Prefix]
         , iif(mm.[oncore --> union: fullname --> fullname] is null and
               [oncore --> union: prefix --> netid] is null and
               [oncore --> union: username --> prefix] is null and
               [oncore --> union: prefix --> prefix] is null and
               [oncore --> union: netid --> netid] is null and
               [oncore --> eml: fullname --> fullname] is null and
               [oncore --> eml: prefix --> netid] is null and
               [oncore --> eml: username --> prefix] is null and
               [oncore --> eml: prefix --> prefix] is null and
               [oncore --> eml: netid --> netid] is null, mm.STAFF_NAME, null) as [Zero Matching Contacts]
    from MatchingsMatrix mm