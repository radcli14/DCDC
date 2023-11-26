using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Mover : MonoBehaviour
{
    public bool beginsVisible = false;
    public float appearTime = 0.0f;
    public float removeTime = 2.5f;
    private float currentTime = 0.0f;
    private readonly float totalTime = 9.0f;
    private readonly float gainFactor = 0.05f;
    public float visibleHeight = 0.1f;
    public float hiddenHeight = 0.0f;

    // Start is called before the first frame update
    void Start()
    {
        // Initialize position to be at the height when visible or hidden, depending on user specification
        if (beginsVisible) {
            transform.Translate((visibleHeight - transform.position.y) * Vector3.up);
        } else {
            transform.Translate((hiddenHeight - transform.position.y) * Vector3.up);
        }
    }

    // Update is called once per frame
    void Update()
    {
        // If time is greater than total time, reset to zero
        if (currentTime > totalTime) {
            currentTime = 0.0f;
        } else {
            currentTime += Time.deltaTime;
        }
        
        // Use a 1st order transition to either translate from hidden to visible, or vice versa
        if (currentTime > appearTime && currentTime < removeTime) {
            transform.Translate(gainFactor * (visibleHeight - transform.position.y) * Vector3.up);
        } else {
            transform.Translate(gainFactor * (hiddenHeight - transform.position.y) * Vector3.up);
        }
    }
}
