//:___________________________________________________________
//  cvulkan  |  Copyright (C) Ivan Mar (sOkam!)  |  MPL-2.0  :
//:___________________________________________________________
pub const cvk = @This();
// const C = @cImport(@cInclude("cvulkan.h"));
const C = @import("./cvulkan/raw.zig");

//______________________________________
// @section Base Types
//____________________________
pub const size       = C.cvk_size;
pub const String     = C.cvk_String;
pub const StringList = C.cvk_StringList;
pub const @"bool"    = C.cvk_bool;
pub const @"false"   = C.cvk_false;
pub const @"true"    = C.cvk_true;
pub const Size2D     = C.cvk_Size2D;


//______________________________________
// @section Version
//____________________________
pub const version = struct {
  pub fn make_api (v :u32, M :u32, m :u32, p :u32) u32 { return (v << 29) | (M << 22) | (m << 12) | p; }
  pub fn make     (        M :u32, m :u32, p :u32) u32 { return cvk.version.make_api(0, M,m,p); }
};


//______________________________________
// @section Application
//____________________________
pub const Application = struct {
  pub const defaults = C.cvk_application_defaults;
};


//______________________________________
// @section Instance
//____________________________
pub const Instance = extern struct {
  ct           :C.VkInstance,
  cfg          :C.VkInstanceCreateInfo,
  allocator    :C.cvk_Allocator,
  application  :C.VkApplicationInfo,
  validation   :C.cvk_Validation,
  extensions   :C.cvk_instance_Extensions,
  layers       :C.cvk_instance_Layers,

  pub const create_args = C.cvk_instance_create_args;
  pub fn create (arg :cvk.Instance.create_args) cvk.Instance { return @bitCast(C.cvk_instance_create(&arg)); }
  pub fn destroy (instance :*cvk.Instance) void {
    C.cvk_instance_destroy(@ptrCast(instance));
  }

  pub const Extensions = extern struct {
    ptr  :cvk.StringList= null,
    len  :cvk.size= 0,
    pub const Required = extern struct {
      user     :cvk.Instance.Extensions= .{},
      system   :cvk.Instance.Extensions= .{},
      cvulkan  :?*cvk.Instance.Extensions= null,
    }; //:: cvk.Instance.Extensions.Required
  }; //:: cvk.Instance.Extensions
}; //:: cvk.Instance


//______________________________________
// @section Device
//____________________________
pub const device = struct {
  pub const Features   = C.cvk_device_Features;
  pub const Extensions = C.cvk_device_Extensions;

  //______________________________________
  // @section Device.Surface
  //____________________________
  pub const Surface   = cvk.device.surface.type;
  pub const surface   = struct {
    pub const @"type" = C.cvk_Surface;
    pub const destroy = C.vkDestroySurfaceKHR;
  }; //:: cvk.device.Surface


  //______________________________________
  // @section Device.Physical
  //____________________________
  pub const Physical = extern struct {
    ct                :C.VkPhysicalDevice,
    id                :u32,
    priv_pad          :[4]c_char,
    queueFamilies     :cvk.device.Queue.Families,
    swapchainSupport  :cvk.device.Swapchain.Support,
    features          :cvk.device.Features,
    properties        :cvk.device.Physical.Properties,
    memory            :cvk.device.Physical.Memory,

    pub const create_args = C.cvk_device_physical_create_args;
    pub fn create (arg :cvk.device.Physical.create_args) cvk.device.Physical {
      return @bitCast(C.cvk_device_physical_create(@constCast(&arg)));
    }

    pub fn destroy (device_physical :*cvk.device.Physical, instance :*cvk.Instance) void {
      C.cvk_device_physical_destroy(@ptrCast(device_physical), &instance.allocator);
    }

    pub const Properties = C.VkPhysicalDeviceProperties;
    pub const Memory     = C.VkPhysicalDeviceMemoryProperties;
  }; //:: cvk.device.Physical


  //______________________________________
  // @section Device.Logical
  //____________________________
  pub const Logical = extern struct {
    ct         :C.VkDevice,
    cfg        :C.VkDeviceCreateInfo,
    features   :cvk.device.Features,
    extensions :cvk.device.Extensions,

    pub const create_args = C.cvk_device_logical_create_args;
    pub fn create (arg :cvk.device.Logical.create_args) cvk.device.Logical {
      return @bitCast(C.cvk_device_logical_create(@constCast(&arg)));
    }

    pub fn destroy (device_logical :*cvk.device.Logical, instance :*cvk.Instance) void {
      C.cvk_device_logical_destroy(@ptrCast(device_logical), &instance.allocator);
    }
  }; //:: cvk.device.Logical


  //______________________________________
  // @section Device.Swapchain
  //____________________________
  pub const Swapchain = extern struct {
    ct              :C.VkSwapchainKHR,
    cfg             :C.VkSwapchainCreateInfoKHR,
    images          :C.cvk_device_swapchain_image_List,
    attachment_cfg  :C.VkAttachmentDescription,
    priv_pad        :[4]c_char,

    pub const create_args = C.cvk_device_swapchain_create_args;
    pub fn create (arg :cvk.device.Swapchain.create_args) cvk.device.Swapchain {
      return @bitCast(C.cvk_device_swapchain_create(@constCast(&arg)));
    }

    pub fn destroy (
        swapchain      : *cvk.device.Swapchain,
        device_logical : *cvk.device.Logical,
        instance       : *cvk.Instance
      ) void {
      C.cvk_device_swapchain_destroy(@ptrCast(swapchain), @ptrCast(device_logical), &instance.allocator);
    }

    pub const Support = C.cvk_device_swapchain_Support;
  }; //:: cvk.device.Swapchain


  //______________________________________
  // @section Device.Queue
  //____________________________
  pub const Queue = extern struct {
    ct        :C.VkQueue,
    cfg       :C.VkDeviceQueueCreateInfo,
    priority  :f32,
    priv_pad  :[4]c_char,

    pub const create_args = C.cvk_device_queue_create_args;
    pub const create = struct {
      pub fn noContext (arg :cvk.device.Queue.create_args) cvk.device.Queue {
        return @bitCast(C.cvk_device_queue_create_noContext(@constCast(&arg)));
      }
      pub fn context (queue :*cvk.device.Queue, device_logical :*cvk.device.Logical) void {
        C.cvk_device_queue_create_context(@ptrCast(queue), @ptrCast(device_logical));
      }
    };

    pub fn destroy (queue :*cvk.device.Queue, instance :*cvk.Instance) void {
      // C.cvk_device_queue_destroy(@ptrCast(&queue), &instance.allocator);
      _=queue; _=instance;
    }

    pub const Families = C.cvk_device_queue_Families;
  }; //:: cvk.device.Queue
}; //:: cvk.device

