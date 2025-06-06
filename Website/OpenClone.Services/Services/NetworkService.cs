using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Azure;
using Microsoft.Extensions.Configuration;
using OpenClone;
using OpenClone.Services;
using OpenClone.Services.Extensions;
using OpenClone.Services.Services;

namespace OpenClone.Services.Services
{
    [Flags]
    public enum CustomHeaders { 
        APIKeyOpenAI=1,
        APIKeyElevenLabs=2,
        ExpectMP3=3,
        ExpectJson=4 
    }

    public class NetworkService
    {
        ConfigurationService _configurationService;
        public NetworkService(ConfigurationService configurationService) 
        {
            _configurationService = configurationService;
        }

        public async static Task DownloadImage(string url, string savePath)
        {
            using (var httpClient = new HttpClient())
            {
                var imageBytes = await httpClient.GetByteArrayAsync(url);
                await File.WriteAllBytesAsync(savePath, imageBytes);
            }
        }

        private void SetHeaders(HttpClient client, CustomHeaders apiKeys)
        {
            client.DefaultRequestHeaders.Accept.Clear();
            if (apiKeys.HasFlag(CustomHeaders.APIKeyOpenAI)) client.DefaultRequestHeaders.Add("Authorization", $"Bearer {_configurationService.GetOpenAIKey()}");
            if (apiKeys.HasFlag(CustomHeaders.APIKeyElevenLabs)) client.DefaultRequestHeaders.Add("xi-api-key", _configurationService.GetElevenLabsKey());
            if (apiKeys.HasFlag(CustomHeaders.ExpectMP3)) client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("audio/mpeg"));
            if (apiKeys.HasFlag(CustomHeaders.ExpectJson)) client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));


            //httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {apiKey}");//
        }

        private async Task<T> CastResponse<T>(HttpContent httpContent, bool expectJson = false)
        {
            if (typeof(T) == typeof(byte[]))
            {
                var contentAsBytes = await httpContent.ReadAsByteArrayAsync();
                return (T)(object)contentAsBytes;
            }
            else if (typeof(T) == typeof(string))
            {
                var contentAsString = await httpContent.ReadAsStringAsync();
                return (T)(object)contentAsString;
            }
            else if (expectJson)
            {
                var responseBody = await httpContent.ReadAsStringAsync();
                return JsonSerializer.Deserialize<T>(responseBody, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
            }
            else
            {
                throw new InvalidOperationException($"Deserialization of type {typeof(T).Name} is not implemented.");
            }
        }

        public async Task Post(string url, object data, CustomHeaders customerHeaders)
        {
            await Post<object>(url, data, customerHeaders);
        }

        public async Task<T> Post<T>(string url, object data, CustomHeaders customerHeaders)
        {
            if(IsFormData(data))
            {
                return await PostFormData<T>(url, data, customerHeaders);
            }
            else
            {
                return await PostJSON<T>(url, data, customerHeaders);
            }
        }

        private bool IsFormData(object data)
        {
            var containsFileStream = false;
            data.IterateOverProperties((name, value) =>
            {
                containsFileStream = containsFileStream || value.IsFileStream();
                return containsFileStream;
            });
            return containsFileStream;
        }

        private async Task<T> PostJSON<T>(string url, object data, CustomHeaders customerHeaders)
        {
            var json = JsonSerializer.Serialize(data);
            var content = new StringContent(json, Encoding.UTF8, "application/json"); // assumes we are sending json

            var client = new HttpClient();
            SetHeaders(client, customerHeaders);

            var response = await client.PostAsync(url, content);
            return await ProcessResponse<T>(response, customerHeaders);
        }

        private async Task<T> PostFormData<T>(string url, object data, CustomHeaders customerHeaders)
        {
            var formData = GetFormData(data);

            var client = new HttpClient();
            SetHeaders(client, customerHeaders);

            var response = await client.PostAsync(url, formData); // <--------------------- i am getting cannot access a disposed object here
            return await ProcessResponse<T>(response, customerHeaders);
        }

        public async Task<T> Get<T>(string url, CustomHeaders customHeaders)
        {
            var client = new HttpClient();
            SetHeaders(client, customHeaders);

            var response = await client.GetAsync(url);
            return await ProcessResponse<T>(response, customHeaders);
        }

        public async Task Delete(string url, CustomHeaders customHeaders)
        {
            var client = new HttpClient();
            SetHeaders(client, customHeaders);

             client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("*/*"));

            var response = await client.DeleteAsync(url);
            await ProcessResponse<string>(response, customHeaders);
        }

        public async Task<T> ProcessResponse<T>(HttpResponseMessage response, CustomHeaders customHeaders)
        {
            if (response.IsSuccessStatusCode)
            {
                return await CastResponse<T>(response.Content, customHeaders.HasFlag(CustomHeaders.ExpectJson));
            }
            else
            {
                string errorContent = await response.Content.ReadAsStringAsync();
                throw new Exception($"Error: {errorContent}, URL: {response.RequestMessage.RequestUri}, Status Code: {response.StatusCode}");
            }
        }

        private MultipartFormDataContent GetFormData(object data)
        {
            var form = new MultipartFormDataContent();
            data.IterateOverProperties((name, value) =>
            {
                // if you need to send multiple files add an else for value.IsArrayOfFileStreams and in your loop run the same logic as you are here.
                if(value.IsFileStream())
                {
                    var fileSteam = (FileStream)value;
                    var fileContent = new StreamContent(fileSteam);
                    fileContent.Headers.ContentDisposition = new ContentDispositionHeaderValue("form-data")
                    {
                        Name = name,
                        FileName = Path.GetFileName(fileSteam.Name),
                    };
                    form.Add(fileContent);
                }
                else
                {
                    form.Add(new StringContent(value.ToString()), name);
                }
            });

            return form;
        }
    }
}
