<%@ Control Language="C#" Inherits="DetectorInspector.Views.ViewUserControl<DetectorInspector.ViewModels.UserProfileViewModel>" %>

Welcome back <%= Html.Encode(Model.Profile.FirstName) %>. 
The current date and time is <%= Html.UtcToLocalDateTime(DateTime.Now.ToUniversalTime()) %>.
Your last login was <%= Html.UtcToLocalDateTime(Model.Profile.LastLoginUtcDate)%>.