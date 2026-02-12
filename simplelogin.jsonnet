local claims = std.extVar('claims');

{
  identity: {
    traits: {
      email: claims.email,
      email_verified: if std.objectHas(claims, 'email_verified') then claims.email_verified else false,
      name: if std.objectHas(claims, 'name') then claims.name else claims.email,
    },
  },
}