open Core.Std

type t =
  { path : string
  }

let create ~path =
  Shell.mkdir path;
  Shell.cd path;
  Git.init ();
  { path = Shell.pwd ()  (* Remember the absolute path *)
  }

let put {path} ~bucket (key, value) =
  Shell.cd path;
  Shell.mkdir bucket;
  let filepath = bucket ^ "/" ^ key in
  Out_channel.write_all filepath ~data:value;
  Git.add ~filepath;
  match Git.status ~filepath with
  | Git.Added ->
    eprintf "Committing: %S. Known status: Added\n%!" filepath;
    Git.commit ~msg:(sprintf "'Add %s'" filepath)

  | Git.Modified ->
    eprintf "Committing: %S. Known status: Modified\n%!" filepath;
    Git.commit ~msg:(sprintf "'Update %s'" filepath)

  | Git.Unchanged ->
    eprintf "Skipping: %S. Known status: Unchanged\n%!" filepath

  | Git.Unexpected status ->
    eprintf "Skipping: %S. Unknown status: %S\n%!" filepath status
