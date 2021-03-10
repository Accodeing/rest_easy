# RestEasy::Mapper

The mapper class is a utility class for use when mapping the API model to/from
your model. While this utility model is available and quite handy for many APIs,
it is not needed. Any place where you can give a mapper you can give any object
that responds to `#call`. This includes singleton classes and procs, or any
class you want to implement.

The `#call` method will be called with the raw attributes and the expected
output is another hash with values matching you models attributes. The provided
mapper class is also written to be compatible with the middleware stack concept,
but that is optional - though easy to implement in your own version.

# Mapping attributes

Any class inheriting from `RestEasy::Mapper` could implement any set of the
following kinds of methods. Your requirements will wary and should this not be
enough flexibility you can always eject and write your own mapper from scratch.

Lets say you get the following from some API:

```
{
  firstName: "Random",
  last_name: 1086854,
  lastNameEncoding: 36,
  AGE: 500,
  Fr0nxID: 013546326576826
}
```

We want to clean up some of the keys, decode the last name, recalculate the age -
that the server gives in months instead of years - and change the external ID
to something more consistent for our system to work with.

##`firstName`

Here we only need to rename the key, the simplest case. There is a helper for
this:

```
copy :firstName, :first_name
```

This will copy the value over to the `mapped_attributes` and rename the
key at the same time. If you want to change the value first you can give a
block or proc as an additional argument. This callable should return the value
you want set in `mapped_attributes`.

```
copy :firstName, :first_name {|x| x }
```

or

```
copy :firstName, :first_name, ->(v){ v }
```

This is also usable with only one argument, if you just want to copy the value
over and keep the name as well:

```
copy :good_name
```

Or with a proc/block to transform the value:

```
copy :choice, ->(v){ v == 'TRUE' }
```

##`last_name`

This requires a bit more control, we need to decode the actual name and that
require access to another attribute, `lastNameEncoding`, as well...

You can implement a method of the same name as the incoming attribute in your
mapper to be called for that attribute. There are three different versions you
can implement, with different arity:

`name( value )` - Simplest form, taking the value from the input and returning
the desired value for the instantiation of your model.

`name( value, attributes )` - Slightly more control where you also get access to
the rest of the incoming attributes, if you need to look at other attributes to
decide what to do with this one. Also returns the desired value.

`name( value, attributes, mapped_attributes )` - Full control of the attributes,
both incoming and resulting, must return a modified version of the
`mapped_attributes` hash. Since you do not know when what method gets called you
can not make assumptions about what values are in `attributes` and
`mapped_attributes`.

You can also implement `before_name` and `after_name` versions of these that are
run right before or after the main `name` method. They are run even if there is
no `name` method defined, so you can implement the `before_name` version alone
if you want to, but only if an attribute with `name` exists. No version of these
methods will be called unless the attribute exists in the input. Renamed
attributes do count however, since renaming is done on the `attributes` and does
not affect the `mapped_attributes`.

```
def last_name( value, attributes )
  encoding = attributes[ :lastNameEncoding ]
  value.to_s( encoding ).capitalize
end
```

##`AGE`

In this case we need to rename the key and change the value. We can use the
attribute name version with arity 3 for this:

```
def AGE( value, _, mapped_attributes )
  mapped_attributes[ :age ] = value % 12
  return mapped_attributes
end
```

Or we can do this:

```
rename: :AGE, :age

def age( value )
  value % 12
end
```

Renaming is done before any of the attribute name methods are called, so it is
the renamed name you should implement the method as.

## `Fr0nxID`

This attribute we don't really want in our final output at all. We could do a
rename and transform on it, but we can also use the `first` or `finally`
methods.

The `first` method is called, well, first ... Even before any renamings are
done. Conversely the `finally` method is the last thing that is called, after
any other transformations.

In this case we can use either one to do the job, so let us show both:

`first` only receives the raw `attributes` as an argument and is expected to
return a hash that will become the initial `mapped_attributes`:

```
def first( attributes )
  require 'digest'

  id = Digest::SHA1.hexdigest( attributes[ :Fr0nxID ])
  return { id: id }
```

`finally` receives both the raw `attributes` and the `mapped_attributes` so far
and should return a final version of the `mapped_attributes`:

```
def first( attributes, mapped_attributes )
  require 'digest'

  id = Digest::SHA1.hexdigest( attributes[ :Fr0nxID ])
  mapped_attributes[ :id ] = id
  return mapped_attributes
```

So very similar, but with access to different versions of the state.

## See also
There are examples of all of these in the test suite. Check out the mapper spec
for some more inspiration.
