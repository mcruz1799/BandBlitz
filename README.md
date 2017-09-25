<div id="wrapper">
  <section id="content">
  <div class="markdown-body padded">
        <ol>
<li>
<li>
<p>We are going to be working with a project known as BandBlitz.  This app allows for bands to post information about themselves as well as a small musical sample.  It also allows guests to post comments about the band for others to see.  Unregistered users can read everything, but can only post comments.  If a band manager is made a user, he/she can update the band's information and remove the band from BandBlitz if they so desire.  Regular band members can update the information, but cannot delete the band's entry.  Administrators can do it all – all CRUD operations on both bands and genres and is the only user that can delete a comment left for a band (in case there is libel, obscene remarks, etc.).  Begin by getting the base project code off of github with the following command:</p>

<pre lang="git"><code>  git clone git://github.com/profh/BandBlitz-67272.git
</code></pre>

<p>Once you get the code, run <code>bundle install</code> to get the gems such as <a href="https://github.com/CanCanCommunity/cancancan">CanCanCan</a> we will need for this lab.</p>
</li>
<li><p>We want to add authorization, but we must first begin by adding authentication.  To do this, create a user model with the following attributes: first_name (string), last_name (string), email (string), role (string), password_digest (string), band_id (integer), and active (boolean).  (Use <code>rails generate model</code> for now; some user views you will need are already included in starter files.) In the migration set the default value of <code>role</code> to "member" and the default value of <code>active</code> to true.  Run <code>rake db:migrate</code> to capture these changes.</p></li>
<li><p>In the <code>User</code> model, create a relationship to Band (and vice-versa).</p></li>
<li>
<p>We also want to use Rails' built-in password management, so add the line <code>has_secure_password</code> to your model as well.  This will create the password-digest, but you will need the bcrypt gem for this to work (make sure it's in your <code>Gemfile</code>).  Add appropriate validation to this model as well as a name method with concatenates the user's first and last names.  As an option, you can also add the following class method to handle logging in via email and use this method later in the sessions_controller (this was demo'd in class last week and we'll point out where it would go later in the lab):</p>

<div class="highlight highlight-ruby"><pre>  <span class="k">def</span> <span class="nc">self</span><span class="o">.</span><span class="nf">authenticate</span><span class="p">(</span><span class="n">email</span><span class="p">,</span><span class="n">password</span><span class="p">)</span>
    <span class="n">find_by_email</span><span class="p">(</span><span class="n">email</span><span class="p">)</span><span class="o">.</span><span class="n">try</span><span class="p">(</span><span class="ss">:authenticate</span><span class="p">,</span> <span class="n">password</span><span class="p">)</span>
  <span class="k">end</span>
</pre></div>

<p>Quick question: you are saving your work to git, right?</p>
</li>
<li>
<p>We are going to go to the ApplicationController and add some methods we want all controllers to have for authentication purposes.  The first will be the <code>current_user</code>, which we will draw from the session hash (if it is saved... will do that in a moment).  We also want to make this a helper method so that our views can access it as well.  We will created a <code>logged_in?</code> method which simply tells us if you are logged in (true if you have a user_id in session hash, i.e., a current_user).  Finally, we will have a method called <code>check_login</code> that we can use as a before_filter in other controllers.  The code would be as follows:</p>

<div class="highlight highlight-ruby"><pre>  <span class="kp">private</span>
  <span class="k">def</span> <span class="nf">current_user</span>
    <span class="vi">@current_user</span> <span class="o">||=</span> <span class="no">User</span><span class="o">.</span><span class="n">find</span><span class="p">(</span><span class="n">session</span><span class="o">[</span><span class="ss">:user_id</span><span class="o">]</span><span class="p">)</span> <span class="k">if</span> <span class="n">session</span><span class="o">[</span><span class="ss">:user_id</span><span class="o">]</span>
  <span class="k">end</span>
  <span class="n">helper_method</span> <span class="ss">:current_user</span>

  <span class="k">def</span> <span class="nf">logged_in?</span>
    <span class="n">current_user</span>
  <span class="k">end</span>
  <span class="n">helper_method</span> <span class="ss">:logged_in?</span>

  <span class="k">def</span> <span class="nf">check_login</span>
    <span class="n">redirect_to</span> <span class="n">login_url</span><span class="p">,</span> <span class="ss">alert</span><span class="p">:</span> <span class="s2">"You need to log in to view this page."</span> <span class="k">if</span> <span class="n">current_user</span><span class="o">.</span><span class="n">nil?</span>
  <span class="k">end</span>
</pre></div>
</li>
<li><p>Now that we have a <code>check_login</code> method in ApplicationController, every other controller will also have it because they inherit from ApplicationController.  Use this method set up a <code>before_action</code> to require that method be run before any action in the GenresController and before all actions except index and show in the BandsController. See the <a href="http://guides.rubyonrails.org/action_controller_overview.html#filters">Rails Guide</a> for more information on filters if you are unsure of how to do this.</p></li>
<li>
<p>We need to set up a UsersController and it will be much like our standard controllers with the following exceptions:</p>

<p>a) we only need new, edit, create, and update actions this simple app (you can add more if you like, but will also need to add views)<br>
b) edit and update should get initial object from <code>current_user</code> method, not an id parameter passed in<br>
c) when a new user is saved during the create method, the user_id should be added to the session hash: <code>session[:user_id] = @user.id</code> and the user should be redirected to <code>home_path</code><br>
d) allow everyone to run the new and create actions, but not the others<br>
e) in the private user_params method, allow all attributes except <code>:password_digest</code> and replace that with <code>:password</code> and <code>:password_confirmation</code></p>

<p>To do this, do <strong>NOT</strong> run the rails generator as you will overwrite the view files I've given you.  Just create an empty file called <code>users_controller.rb</code> and build this controller manually. (Not hard; look at past projects/labs if you are unsure how to do this.)</p>
</li>
<li>
<p>We also need a SessionsController to handle logging in for users who already exist in the system.  We need a new method which is essentially blank, but let's the user get a login form (provided).  We need a create method which tries to authenticate and if successful sets the user_id in session.  Finally, we need a destroy method to for logout which destroys the user_id in session.  In the interest of time, the code for all this can be seen below:</p>

<div class="highlight highlight-ruby"><pre>  <span class="k">class</span> <span class="nc">SessionsController</span> <span class="o">&lt;</span> <span class="no">ApplicationController</span>
    <span class="k">def</span> <span class="nf">new</span>
    <span class="k">end</span>

    <span class="k">def</span> <span class="nf">create</span>
      <span class="n">user</span> <span class="o">=</span> <span class="no">User</span><span class="o">.</span><span class="n">find_by_email</span><span class="p">(</span><span class="n">params</span><span class="o">[</span><span class="ss">:email</span><span class="o">]</span><span class="p">)</span>
      <span class="k">if</span> <span class="n">user</span> <span class="o">&amp;&amp;</span> <span class="no">User</span><span class="o">.</span><span class="n">authenticate</span><span class="p">(</span><span class="n">params</span><span class="o">[</span><span class="ss">:email</span><span class="o">]</span><span class="p">,</span> <span class="n">params</span><span class="o">[</span><span class="ss">:password</span><span class="o">]</span><span class="p">)</span>
        <span class="n">session</span><span class="o">[</span><span class="ss">:user_id</span><span class="o">]</span> <span class="o">=</span> <span class="n">user</span><span class="o">.</span><span class="n">id</span>
        <span class="n">redirect_to</span> <span class="n">home_path</span><span class="p">,</span> <span class="ss">notice</span><span class="p">:</span> <span class="s2">"Logged in!"</span>
      <span class="k">else</span>
        <span class="n">flash</span><span class="o">.</span><span class="n">now</span><span class="o">.</span><span class="n">alert</span> <span class="o">=</span> <span class="s2">"Email or password is invalid"</span>
        <span class="n">render</span> <span class="s2">"new"</span>
      <span class="k">end</span>
    <span class="k">end</span>

    <span class="k">def</span> <span class="nf">destroy</span>
      <span class="n">session</span><span class="o">[</span><span class="ss">:user_id</span><span class="o">]</span> <span class="o">=</span> <span class="kp">nil</span>
      <span class="n">redirect_to</span> <span class="n">home_path</span><span class="p">,</span> <span class="ss">notice</span><span class="p">:</span> <span class="s2">"Logged out!"</span>
    <span class="k">end</span>
  <span class="k">end</span>
</pre></div>

<p>Note: if you created the class method earlier in the User model, you could use that instead to rewrite/replace the first two lines of the create action.  This is optional, but it would be a good learning exercise at some point to do this and make sure you have a good grasp of what is happening when creating a user's session.</p>
</li>
<li>
<p>Now we have controllers and the views were already given to us, but without routes these controllers will never be called.  So go to <code>config/routes.rb</code> and add the following routes:</p>

<div class="highlight highlight-ruby"><pre>  <span class="n">resources</span> <span class="ss">:users</span>
  <span class="n">resources</span> <span class="ss">:sessions</span>
  <span class="n">get</span> <span class="s1">'user/edit'</span> <span class="o">=&gt;</span> <span class="s1">'users#edit'</span><span class="p">,</span> <span class="ss">:as</span> <span class="o">=&gt;</span> <span class="ss">:edit_current_user</span>
  <span class="n">get</span> <span class="s1">'signup'</span> <span class="o">=&gt;</span> <span class="s1">'users#new'</span><span class="p">,</span> <span class="ss">:as</span> <span class="o">=&gt;</span> <span class="ss">:signup</span>
  <span class="n">get</span> <span class="s1">'login'</span> <span class="o">=&gt;</span> <span class="s1">'sessions#new'</span><span class="p">,</span> <span class="ss">:as</span> <span class="o">=&gt;</span> <span class="ss">:login</span>
  <span class="n">get</span> <span class="s1">'logout'</span> <span class="o">=&gt;</span> <span class="s1">'sessions#destroy'</span><span class="p">,</span> <span class="ss">:as</span> <span class="o">=&gt;</span> <span class="ss">:logout</span>
</pre></div>
</li>
<li>
<p>Add a default user (admin) to the system using migrations (since all new sign-ups are going to be members only unless an admin is signing them up and chooses a different level).  An example of the up and down methods for this migration are below; create a new migration with <code>rails g migration [NAME]</code> (remove the change method in this new migration):</p>

<div class="highlight highlight-ruby"><pre>  <span class="k">def</span> <span class="nf">up</span>
    <span class="n">admin</span> <span class="o">=</span> <span class="no">User</span><span class="o">.</span><span class="n">new</span>
    <span class="n">admin</span><span class="o">.</span><span class="n">first_name</span> <span class="o">=</span> <span class="s2">"Admin"</span>
    <span class="n">admin</span><span class="o">.</span><span class="n">last_name</span> <span class="o">=</span> <span class="s2">"Admin"</span>
    <span class="n">admin</span><span class="o">.</span><span class="n">email</span> <span class="o">=</span> <span class="s2">"admin@example.com"</span>
    <span class="n">admin</span><span class="o">.</span><span class="n">password</span> <span class="o">=</span> <span class="s2">"secret"</span>
    <span class="n">admin</span><span class="o">.</span><span class="n">password_confirmation</span> <span class="o">=</span> <span class="s2">"secret"</span>
    <span class="n">admin</span><span class="o">.</span><span class="n">role</span> <span class="o">=</span> <span class="s2">"admin"</span>
    <span class="n">admin</span><span class="o">.</span><span class="n">save!</span>
  <span class="k">end</span>

  <span class="k">def</span> <span class="nf">down</span>
    <span class="n">admin</span> <span class="o">=</span> <span class="no">User</span><span class="o">.</span><span class="n">find_by_email</span> <span class="s2">"admin@example.com"</span>
    <span class="no">User</span><span class="o">.</span><span class="n">delete</span> <span class="n">admin</span>
  <span class="k">end</span>
</pre></div>
</li>
<li>
<p>Test this out by attempting to log in as the default user.  This seems to work (you get a flash message saying 'Logged in!') but it would be nice to add some personal information to the page.  In the application layout file, add to the div id="login" the following and reload the page to verify:</p>

<div class="highlight highlight-erb"><pre><span class="x">  </span><span class="cp">&lt;%</span> <span class="k">if</span> <span class="n">logged_in?</span> <span class="cp">%&gt;</span><span class="x"></span>
<span class="x">    </span><span class="cp">&lt;%=</span> <span class="n">link_to</span> <span class="s1">'Logout'</span><span class="p">,</span> <span class="n">logout_path</span> <span class="cp">%&gt;</span><span class="x"></span>
<span class="x">    &lt;br&gt;[</span><span class="cp">&lt;%=</span> <span class="n">current_user</span><span class="o">.</span><span class="n">proper_name</span> <span class="cp">%&gt;</span><span class="x">:</span><span class="cp">&lt;%=</span> <span class="n">current_user</span><span class="o">.</span><span class="n">role</span> <span class="cp">%&gt;</span><span class="x">]</span>
<span class="x">  </span><span class="cp">&lt;%</span> <span class="k">else</span> <span class="cp">%&gt;</span><span class="x"></span>
<span class="x">    </span><span class="cp">&lt;%=</span> <span class="n">link_to</span> <span class="s1">'Login'</span><span class="p">,</span> <span class="n">login_path</span> <span class="cp">%&gt;</span><span class="x"></span>
<span class="x">  </span><span class="cp">&lt;%</span> <span class="k">end</span> <span class="cp">%&gt;</span><span class="x"></span>
</pre></div>
</li>
</ol>

<hr>

<h1>
<span class="mega-icon mega-icon-issue-opened"></span> Stop</h1>

<p>Show a TA that you have the authentication functionality set up and working as instructed and that the code is properly saved to git. Make sure the TA initials your sheet.</p>

<hr>

<ol>
<li><p>With authentication under our belts, let's tackle the issue of authorization.  We will be using the CanCan gem to help with this; feel free to open the <a href="https://github.com/CanCanCommunity/cancancan">documentation for this gem</a> and reference it if you have questions.  Using CanCan we will first tell Rails what each user role can do in the system (stored in a file called 'ability') and then test in our controllers and/or views whether that user can? access selected functions on the app.  </p></li>
<li><p>We will start by defining some abilities.  The cancan gem is looking for a model file called 'ability.rb' and located in <code>app/models</code>.  The file can be created by running on the command line <code>rails generate cancan:ability</code>.  Looking at this file in the models directory, you can see it is an example of a non-ActiveRecord model.  (Most, but not all models inherit from ActiveRecord.  Since abilities are defined in that file, there is no need for database access so we don't need the power of ActiveRecord.)  The initialize method is there (with lots of helpful comments), but we need to add some basic abilities.  We also see that the method takes a user as an argument, but what if someone is not logged in yet?  Will it blow up in our face?  To prevent this, we add the line <code>user ||= User.new</code> to the initialize method.</p></li>
<li>
<p>Now it is time to add the all-powerful admin user; admins can do everything and guests can only read for now.  To make this happen, add the following code to the initialize method:</p>

<div class="highlight highlight-ruby"><pre>  <span class="k">if</span> <span class="n">user</span><span class="o">.</span><span class="n">role?</span> <span class="ss">:admin</span>
    <span class="n">can</span> <span class="ss">:manage</span><span class="p">,</span> <span class="ss">:all</span>
  <span class="k">else</span>
    <span class="n">can</span> <span class="ss">:read</span><span class="p">,</span> <span class="ss">:all</span>
  <span class="k">end</span>
</pre></div>

<p>The user model needs a method called <code>role?</code> that compares a user's role in the system with the role we are testing for.  So this can all work properly, add the following code to the User model: </p>

<div class="highlight highlight-ruby"><pre>  <span class="no">ROLES</span> <span class="o">=</span> <span class="o">[[</span><span class="s1">'Administrator'</span><span class="p">,</span> <span class="ss">:admin</span><span class="o">]</span><span class="p">,</span><span class="o">[</span><span class="s1">'Band Manager'</span><span class="p">,</span> <span class="ss">:manager</span><span class="o">]</span><span class="p">,</span><span class="o">[</span><span class="s1">'Band Member'</span><span class="p">,</span> <span class="ss">:member</span><span class="o">]]</span>

  <span class="k">def</span> <span class="nf">role?</span><span class="p">(</span><span class="n">authorized_role</span><span class="p">)</span>
    <span class="k">return</span> <span class="kp">false</span> <span class="k">if</span> <span class="n">role</span><span class="o">.</span><span class="n">nil?</span>
    <span class="n">role</span><span class="o">.</span><span class="n">to_sym</span> <span class="o">==</span> <span class="n">authorized_role</span>
  <span class="k">end</span>
</pre></div>
</li>
</ol>

<p>Now an admin can 'manage' (run all CRUD operations) for all models while guests can only read content (but for all models). </p>

<ol>
<li><p>Now that we have this simple authorization in place, time to go put constraints on the controllers so they don't give the user access to app functionality they aren't entitled to.  Open the band controller and add to the <code>new</code> action the following line: <code>authorize! :new, @band</code>.  What this is doing is raising an exception if the user does not have the ability to create a new band.  We will add the same line to the create method just in case someone is trying to add a new band without going through the interface (we will learn about this soon enough).  In the edit and update methods add the line <code>authorize! :update, @band</code> and <code>authorize! :destroy, @band</code> to the destroy method. You will need to comment out your <code>before_filter</code> callbacks to make sure that CanCan can do its job (otherwise, you will hit the <code>before_filter</code> and get redirected before the <code>authorize!</code> command is called). </p></li>
<li><p>Test out your work by logging in as an admin (small login link in upper right corner) and see that you can access everything.  Logout and try to access restricted functionality; you should get a <code>CanCan::AccessDenied</code> exception.  If do not get this exception, please see a TA for assistance before going on further.  Now we need to add similar restraints to the genre controller (try it and see that access is unrestricted), but you realize this could be tedious for a larger project to do this for every action in every controller.  Not to worry, CanCan has a shortcut for us; add to the top of the genres_controller  <code>authorize_resource</code> and it will be as if you added the <code>authorize!</code> method to each action in the controller.</p></li>
<li>
<p>Let's fix up that exception page – informative to developers, but not appropriate for general users.  Go to the Application controller and add the following method:</p>

<div class="highlight highlight-ruby"><pre>  <span class="n">rescue_from</span> <span class="no">CanCan</span><span class="o">::</span><span class="no">AccessDenied</span> <span class="k">do</span> <span class="o">|</span><span class="n">exception</span><span class="o">|</span>
    <span class="n">flash</span><span class="o">[</span><span class="ss">:error</span><span class="o">]</span> <span class="o">=</span> <span class="s2">"Go away or I shall taunt you a second time."</span>
    <span class="n">redirect_to</span> <span class="n">home_path</span>
  <span class="k">end</span>
</pre></div>

<p>If you don't like <a href="https://www.youtube.com/watch?v=A8yjNbcKkNY">Monty Python</a> or you just want to follow some of the design principles discussed in class, you can change the text to a more appropriate message.  [Quick: what is wrong with this message?  If you don't immediately know the answer, go back and review your design notes and book.]</p>
</li>
<li>
<p>Time to clean up the views a bit.  We know that from our design principles, if the user doesn't have access to certain functionality, it is better not to display these options.  [Again: why?  What design principles specifically are being violated?  You should know this and if not, go back and study.]  Go to the index page of the bands view and you will notice that there are three sets of comments telling us to essentially replace with some type of access control.  For the first one – edit icon and link – wrap the line in the following:</p>

<div class="highlight highlight-erb"><pre><span class="x">  </span><span class="cp">&lt;%</span> <span class="k">if</span> <span class="n">can?</span> <span class="ss">:update</span><span class="p">,</span> <span class="n">band</span> <span class="cp">%&gt;</span><span class="x"></span>
<span class="x">    </span><span class="cp">&lt;%=</span> <span class="n">link_to</span> <span class="o">.</span><span class="n">.</span><span class="o">.</span> <span class="cp">%&gt;</span><span class="x"></span>
<span class="x">  </span><span class="cp">&lt;%</span> <span class="k">end</span> <span class="cp">%&gt;</span><span class="x"></span>
</pre></div>

<p>What we are doing here is testing whether the user has the access rights of the user to see if he/she has the ability to update this particular band.  Add a similar control to the delete icon and link.  After that, fix the new band link with the following:</p>

<div class="highlight highlight-erb"><pre><span class="x">  </span><span class="cp">&lt;%</span> <span class="k">if</span> <span class="n">can?</span> <span class="ss">:create</span><span class="p">,</span> <span class="no">Band</span> <span class="cp">%&gt;</span><span class="x"></span>
<span class="x">    &lt;p&gt;</span><span class="cp">&lt;%=</span> <span class="n">link_to</span> <span class="s2">"Create New Band"</span><span class="p">,</span> <span class="n">new_band_path</span> <span class="cp">%&gt;</span><span class="x">&lt;/p&gt;</span>
<span class="x">  </span><span class="cp">&lt;%</span> <span class="k">end</span> <span class="cp">%&gt;</span><span class="x"></span>
</pre></div>
</li>
<li>
<p>This is nice, but what about managers and members?  They have partial access to update|destroy, but only for their own band.  To do this, we have to modify 'ability.rb' to include these users.  In the file after the admin is defined, but before the <code>else</code> that sets the guest users, add the following:</p>

<div class="highlight highlight-ruby"><pre>  <span class="k">elsif</span> <span class="n">user</span><span class="o">.</span><span class="n">role?</span> <span class="ss">:manager</span>
    <span class="n">can</span> <span class="ss">:update</span><span class="p">,</span> <span class="no">Band</span> <span class="k">do</span> <span class="o">|</span><span class="n">band</span><span class="o">|</span>  
      <span class="n">band</span><span class="o">.</span><span class="n">id</span> <span class="o">==</span> <span class="n">user</span><span class="o">.</span><span class="n">band_id</span>
    <span class="k">end</span>
    <span class="n">can</span> <span class="ss">:destroy</span><span class="p">,</span> <span class="no">Band</span> <span class="k">do</span> <span class="o">|</span><span class="n">band</span><span class="o">|</span>  
      <span class="n">band</span><span class="o">.</span><span class="n">id</span> <span class="o">==</span> <span class="n">user</span><span class="o">.</span><span class="n">band_id</span>
    <span class="k">end</span>
  <span class="k">elsif</span> <span class="n">user</span><span class="o">.</span><span class="n">role?</span> <span class="ss">:member</span>
    <span class="n">can</span> <span class="ss">:update</span><span class="p">,</span> <span class="no">Band</span> <span class="k">do</span> <span class="o">|</span><span class="n">band</span><span class="o">|</span>  
      <span class="n">band</span><span class="o">.</span><span class="n">id</span> <span class="o">==</span> <span class="n">user</span><span class="o">.</span><span class="n">band_id</span>
    <span class="k">end</span>
  <span class="k">end</span>
</pre></div>

<p>What this says in each case is that the user (manager or member) has the ability to perform the operation specified on Band objects if the id of the band equals the user's band_id.  Now if you log in as a manager [you'll need to create a band and some genres as well as manager and members], you should see links for editing/deleting the band, but not for others.  Likewise, logging in as a member should show the update functionality for the band is there and working, but others are not.  Get the TA to verify this and mark off the checkpoint.</p>
</li>
</ol>

<hr>

<h1>
<span class="mega-icon mega-icon-issue-opened"></span> Stop</h1>

<p>Show a TA that you have the authorization functionality set up for all three user types and working as instructed and that the code is properly saved to git. Make sure the TA initials your sheet.</p>

<hr>

<p>If time allows during lab, challenge yourself by extending this project – add the ability of anyone (even guests) to write comments about a particular band.  [This will require a Comment model and appropriate support from views and controllers.] Comments should be displayed only on the band's show details page and place a form for new comments should be there as well.  Comments may be deleted only by an admin.  (You shouldn't even see the option if you are not an admin.)  Again this is optional but an excellent exercise when you have the time, but not essential for today.</p>
  </div>
  
