import stdlib.apis.{facebook, facebook.auth, facebook.graph}
import stdlib.themes.bootstrap.css

type Login.user = {unlogged} or {User.t user}

module Login {
	config = {
		app_id:  "121883501319223",
		api_key: "121883501319223",
		app_secret: "fd23bd0b580af141cf76f428e0e01222"
	}
	
	FBA 	  = FbAuth(config)
	FBG 	  = FbGraph
	login_url = FBA.user_login_url([], redirect)
 	redirect  = "http://localhost:8080/connect"

 	state = UserContext.make(Login.user {unlogged})

 	/**
 	 * The login page
 	 */ 
	function page() {
		xhtml = <>
			<div id=#title class="navbar navbar-fixed-top">
	      		<div class=navbar-inner> 
	      			<div class="container-fluid">
	      				<a href="/" class="brand hidden-phone hidden-tablet">
	      					<img alt="Opa" src="/resources/img/opa-logo.png" class="logo">
	      				</a>
	      			</div>
	      		</div>
	    	</div>
			<div class="container">
		      <div class="form-signin">
		        <h2 class="form-signin-heading">Please sign in</h2>
		        <input id=#username type="text" class="input-block-level" placeholder="Username">
		        <input id=#password type="password" class="input-block-level" placeholder="Password">
		        <label class="checkbox">
		          <input type="checkbox" value="remember-me"> Remember me
		        </label>
		        <button class="btn btn-large btn-primary" type="submit" onclick={login}>Sign in</button>
		        <a href="{login_url}" class="btn btn-large btn-info" >Sign in with Facebook</a>
		      </div>
    		</div>
		</>
		Resource.html("Login",xhtml)
	}

	function show_login(_){ Dom.show(#login_form) }

	function login(_) {
		username = Dom.get_value(#username)
		password = Dom.get_value(#password)
		match(Model.auth(username,password)){
		case {none}: Client.reload()
	  	case {some:user}: {
	      	UserContext.change(function(_){~{user}},state)
	      	Client.goto("/")
	  	}}
	}

	function logout(_){
		UserContext.remove(state)
		Client.reload()
	}

	function logged() {
		match(UserContext.get(state)){
		case {unlogged}: {false}
		case {user:_}  : {true}
		}
	}

	function get_user() {
		match(UserContext.get(state)){
		case {unlogged}: "anonymous"
		case ~{user}:    user.username
		}
	}

	/* Auxiliary function for processing JSON data obtained from Facebook Graph
    API. Gets an [obj]ect and tries to extract field named [field] */
	function extract_field(obj, field) {
	  match (List.assoc(field, obj.data)) {
	    case {some: {String: v}}: some(v)
	    default: none
	  }
	}

	 /* Returns the name of the currently authenticated Facebook user */
	function get_name(token) {
	  opts = { FBG.Read.default_object with token:token.token }
	  match (FBG.Read.object("me", opts)) {
	  case {~object}: extract_field(object, "name")
	  default: none
	  }
	}

	function connect(data) {
		/** xhtml = match (FBA.get_token_raw(data, redirect)) {
		case {~token}: {
			jlog("ok!")
			match(get_name(token)) {
		    	case {some: name}: show_box("success", "Hello, {name}! This is the list of your friends:", <></>)
		    	default: show_box("error", "Error getting your name", <></>)
		    }
		}			
		case ~{error}: {
			jlog("error {error.error_description}")
			show_box("error", error.error, <>{error.error_description}</>)
		}} */

		Resource.html("connect",<></>)
	}
}